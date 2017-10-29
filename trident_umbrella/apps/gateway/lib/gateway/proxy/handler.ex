require IEx


defmodule Gateway.Proxy.Handler do
  @moduledoc """
  Provides request functions.
  """

  use Plug.Builder
  import Plug.Conn
  require Logger

  alias Plug.Adapters.Cowboy, as: PlugCowboy

  alias Gateway.Plugs.HandleLogin           # process login POST:
                                            # create session token in Auth.
                                            # adds trident_key to session.
                                            # redirects back
  alias Gateway.Plugs.CheckPolicies         # adds protected_route? param
  alias Gateway.Plugs.AuthenticateSession   # adds current_user if session token
  alias Gateway.Plugs.Proxy                 # call target with web client and
                                            # return with streaming

  if Mix.env == :dev do
    use Plug.Debugger, otp_app: :gateway
  end

  alias Poison

  @default_schemes [:http, :https]
  @valid_secret String.duplicate("abcdef0123456789", 8)
  @secret_key_base "9TeyHMxOPQw6ChuTUDVyI399hEV0QMWNIvzw95z5olLrS3fLIE3OwhLqHdSEZ9eU"

  plug :put_secret_key_base
  # Use the session plug with the table name
  plug Plug.Session, store: :cookie,
                     key: "_trident_session",
                     secret: @valid_secret,
                     encryption_salt: "-- LONG STRING WITH AT LEAST 64 BYTES --",
                     signing_salt: "-- LONG STRING WITH AT LEAST 64 BYTES --",
                     key_length: 64,
                     log: :debug

  # pipeline
  #
  plug Plug.Logger
  plug Plug.Parsers, parsers: [:urlencoded]

  plug HandleLogin, create_session_url: "/login"
  plug CheckPolicies, paths: ["/upload"]
  plug AuthenticateSession
  plug Proxy


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

  def add_user_info_cookie(conn) do
    user = conn.assigns[:current_user]
    if user do
      IO.puts "add_user_info cookie = #{inspect user}"
      user_info = user_info(user)
      IO.puts "user_info str = #{inspect user_info}"

      new_conn = conn
      |> put_resp_cookie("trident_user_email", user.email)
      |> put_resp_cookie("trident_user_first_name", user.first_name)
      |> put_resp_cookie("trident_user_last_name", user.last_name)

      IO.puts "after add user info"
      IO.inspect new_conn
      new_conn
    else
      conn
    end
  end

  def user_info(user) do
    %{email: user.email, first_name: user.first_name, last_name: user.last_name}
  end

  def allow_assets(conn) do
    # accept = Plug.Conn.get_req_header(conn, "accept") |> List.last
    ext = Path.extname(conn.request_path) |> String.downcase
    asset_extensions = ~w(.css .js .jpg .png .gif .bmp .ico)
    ext in asset_extensions
  end

  def request_login?(conn) do
    conn.request_path == "/login"
  end

  def root_uri(conn) do
    target_proxy(conn)[:to]
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


  def target_proxy(conn) do
    proxies()
    |> Enum.reduce([], fn proxy, acc ->
      if proxy.port == conn.port, do: [proxy | acc], else: acc
    end)
    |> Enum.at(0)
  end


  # defp read_request(conn, req_body, res_body, status) do
  #   conn
  #   |> send_resp(status, res_body)
  # end

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

  def valid_secret do
    @valid_secret
  end

  def secret_key_base do
    @secret_key_base
  end

end
