require IEx;

defmodule Gateway.Proxy.Handler do
  @moduledoc """
  Provides request functions.
  """

  use Plug.Builder
  import Plug.Conn
  require Logger


  alias Plug.Conn
  alias Plug.Adapters.Cowboy, as: PlugCowboy
  alias Gateway.Policy
  alias Gateway.Web
  alias Directory.User

  if Mix.env == :dev do
    use Plug.Debugger, otp_app: :gateway
  end

  alias Poison

  @default_schemes [:http, :https]

  plug Plug.Logger
  plug :dispatch
  plug Plug.Parsers, parsers: [:urlencoded]

  @valid_secret String.duplicate("abcdef0123456789", 8)
  @secret_key_base "9TeyHMxOPQw6ChuTUDVyI399hEV0QMWNIvzw95z5olLrS3fLIE3OwhLqHdSEZ9eU"

  # Use the session plug with the table name
  plug Plug.Session, store: :cookie,
                     key: "_trident_session",
                     secret: @valid_secret,
                     encryption_salt: "-- LONG STRING WITH AT LEAST 64 BYTES --",
                     signing_salt: "-- LONG STRING WITH AT LEAST 64 BYTES --",
                     key_length: 64,
                     log: :debug

  plug :put_secret_key_base
  def put_secret_key_base(conn, _) do
    put_in conn.secret_key_base, @secret_key_base
  end




  # Same as Plug.Conn
  # https://github.com/elixir-lang/plug/blob/576c04c2cba778f1ac9ca28aa71c50efa1046b50/lib/plug/conn.ex#L125

  @type param :: binary | [param]

  @doc """
  Start Cowboy http process with localhost and arbitrary port.
  Clients access to local Cowboy process with potocol.
  """
  @spec start_link([binary]) :: pid
  def start_link([proxy, module_name]) do
    msg = "Running #{__MODULE__} on http://localhost:#{proxy.port} named #{module_name}, timeout: #{req_timeout()}"
    Logger.info fn -> msg end
    PlugCowboy.http(__MODULE__, [], cowboy_options(proxy.port, module_name))
  end

  # see https://github.com/elixir-lang/plug/blob/master/lib/plug/adapters/cowboy.ex#L5
  defp cowboy_options(port, module_name),
    do: [port: port, ref: String.to_atom(module_name), timeout: req_timeout()]

  defp req_timeout,
    do: Application.get_env :gateway, :timeout, 10_000

  @doc """
  Dispatch connection.
  """
  @spec dispatch(Plug.Conn.t, param) :: Plug.Conn.t
  def dispatch(conn, _opts) do
    IO.puts "dispatch"
    IO.puts "...conn port = #{inspect conn.port}"
    IO.puts "...conn method = #{inspect conn.method}"
    IO.puts "...conn request path = #{inspect conn.request_path}"

    conn = put_secret_key_base(conn, "")

    cond do
      request_login?(conn) ->
        Logger.debug fn -> "request is login !!!" end
        Web.Login.create_session(conn, target_proxy(conn)[:to])

      allow_assets(conn) ->
        Logger.debug fn -> "request assets !!!" end
        finish_dispatch(conn)

      Policy.protected_route?(conn) ->
        Logger.debug fn -> "request is protected_route !!!" end

        case authenticate(conn) do
          nil  ->
            Logger.debug fn -> "authenticate session failed !!!" end
            Web.Login.new_login(conn)

          email ->
            Logger.debug fn -> "authenticated #{email}, need to pass" end
            finish_dispatch(conn)
        end

      true ->
        Logger.debug "request is NOT a protected_route !!!"

        finish_dispatch(conn)
    end

  end

  def allow_assets(conn) do
    IO.puts "allow assets"
    accept = Plug.Conn.get_req_header(conn, "accept") |> List.last
    IO.puts "accept = #{inspect accept}"
    IO.puts "conn request path = #{conn.request_path}"
    ext = Path.extname(conn.request_path) |> String.downcase
    asset_extensions = ~w(.css .js .jpg .png .gif .bmp .ico)
    ext in asset_extensions
  end

  def request_login?(conn) do
    conn.request_path == "/login"
  end

  def root_uri(conn) do
    IO.puts "root uri"
    base = target_proxy(conn)[:to]
    IO.puts "base is #{inspect base}"
    base
  end

  @doc """
  Finish dispatching connection for authenticated or route not protected.
  """
  def finish_dispatch(conn) do
    IO.puts "finish dispatch"

    {:ok, client} =
      conn.method
      |> String.downcase
      |> String.to_atom
      |> HTTPoison.request(uri(conn), "", conn.req_headers,  options())

    {conn, ""}
    |> call_proxy(client)
  end

  # HTTPoison.request(:get, "http://localhost:3000", "", [], [hackney: [{:follow_redirect, true}]])
  # this works for redirects ... like google
  #
  defp options do
    [
      connect_timeout: req_timeout(),
      recv_timeout: req_timeout(),
      ssl_options: [],
      max_redirects: 5,
      follow_redirect: true
    ]
  end

  @spec uri(Plug.Conn.t) :: String.t
  def uri(conn) do
    # IO.puts "uri"
    base = gen_path conn, target_proxy(conn)
    IO.puts "base = #{inspect base}"
    case conn.query_string do
      "" ->
        base
      query_string ->
        "#{base}?#{query_string}"
    end
  end

  @doc ~S"""
  Get proxy defined in config/config.exs

  ## Example

  iex> HttpProxy.Handle.proxies
  [%{port: 8080, to: "http://google.com"}, %{port: 8081, to: "http://www.google.co.jp"}]
  """
  @spec proxies() :: []
  def proxies,
    do: Application.get_env :gateway, :proxies, nil

  @doc ~S"""
  Get schemes which is defined as deault.

  ## Example

  iex> HttpProxy.Handle.schemes
  [:http, :https]
  """
  @spec schemes() :: []
  def schemes,
    do: @default_schemes


  defp call_proxy({conn, _req_body}, client) do
    Logger.debug fn -> "call proxy: request path: #{gen_path(conn, target_proxy(conn))}" end
    headers = conn.req_headers |> Enum.into(%{})
    # Logger.debug fn -> "#{__MODULE__}.call_proxy, :ok, headers: #{headers |> Poison.encode!}, body: #{client.body}, status: #{client.status_code}" end

    conn
    |> send_resp(client.status_code, client.body)
  end

  # defp write_proxy({conn, _req_body}, client) do
  #   IO.puts "write proxy"
  #   case read_body(conn, [read_timeout: req_timeout()]) do
  #     {:ok, body, conn} ->
  #     Logger.debug fn -> "request path: #{gen_path(conn, target_proxy(conn))}" end
  #     Logger.debug fn -> "#{__MODULE__}.write_proxy, :ok, headers: #{conn.req_headers |> Poison.encode!}, body: #{body}" end
  #       HTTPoison.send_body client, body
  #       {conn, body}
  #     {:more, body, conn} ->
  #     Logger.debug fn -> "request path: #{gen_path(conn, target_proxy(conn))}" end
  #     Logger.debug fn -> "#{__MODULE__}.write_proxy, :more, body: #{body}" end
  #       HTTPoison.send_body client, body
  #       write_proxy {conn, ""}, client
  #       {conn, body}
  #     {:error, term} ->
  #       Logger.error term
  #   end
  # end

  # defp read_proxy({conn, req_body}, client) do
  #   IO.puts "read proxy"
  #
  #   case HTTPoison.start_response client do
  #     {:ok, status, headers, client} ->
  #     Logger.debug fn -> "request path: #{gen_path(conn, target_proxy(conn))}" end
  #     Logger.debug fn -> "#{__MODULE__}.read_proxy, :ok, headers: #{headers |> Poison.encode!}, status: #{status}" end
  #       {:ok, res_body} = HTTPoison.body client
  #       read_request(%{conn | resp_headers: headers}, req_body, res_body, status)
  #     {:error, message} ->
  #     Logger.debug fn -> "request path: #{gen_path(conn, target_proxy(conn))}" end
  #     Logger.debug fn -> "#{__MODULE__}.read_proxy, :error, message: #{message}" end
  #       read_request(%{conn | resp_headers: conn.resp_headers}, req_body, Atom.to_string(message), 408)
  #   end
  # end

  defp read_request(conn, req_body, res_body, status) do
    conn
    |> send_resp(status, res_body)
  end

  defp gen_path(conn, proxy) when proxy == nil do
    case conn.scheme do
      s when s in @default_schemes ->
        %URI{%URI{} | scheme: Atom.to_string(conn.scheme), host: conn.host, path: conn.request_path}
        |> URI.to_string
      _ ->
        raise ArgumentError, "no scheme"
    end
  end

  defp gen_path(conn, proxy) do
    uri = URI.parse proxy.to
    %URI{uri | path: conn.request_path}
    |> URI.to_string
  end

  defp target_proxy(conn) do
    proxies()
    |> Enum.reduce([], fn proxy, acc ->
      if proxy.port == conn.port, do: [proxy | acc], else: acc
    end)
    |> Enum.at(0)
  end

  defp authenticate(conn) do
    IO.puts "authenticate"

    opts = Plug.Session.init(store: :cookie, key: "_trident_session", secret: @valid_secret, signing_salt: "cookie store signing salt")
    conn
    |> Plug.Session.call(opts)
    |> fetch_session
    |> get_session(:trident_key)
    |> IO.inspect
    |> Auth.get_session
  end

  def valid_secret do
    @valid_secret
  end

  def secret_key_base do
    @secret_key_base
  end

end
