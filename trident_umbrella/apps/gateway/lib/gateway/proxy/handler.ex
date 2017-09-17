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

  if Mix.env == :dev do
    use Plug.Debugger, otp_app: :gateway
  end

  alias Poison

  @default_schemes [:http, :https]

  plug Plug.Logger
  plug :dispatch

  # Same as Plug.Conn
  # https://github.com/elixir-lang/plug/blob/576c04c2cba778f1ac9ca28aa71c50efa1046b50/lib/plug/conn.ex#L125

  @type param :: binary | [param]

  @doc """
  Start Cowboy http process with localhost and arbitrary port.
  Clients access to local Cowboy process with potocol.
  """
  @spec start_link([binary]) :: pid
  def start_link([proxy, module_name]) do
    IO.puts "start_link for #{proxy.port}"
    msg = "Running #{__MODULE__} on http://localhost:#{proxy.port} named #{module_name}, timeout: #{req_timeout()}"
    Logger.info fn -> msg end
    PlugCowboy.http(__MODULE__, [], cowboy_options(proxy.port, module_name))
  end

  # see https://github.com/elixir-lang/plug/blob/master/lib/plug/adapters/cowboy.ex#L5
  defp cowboy_options(port, module_name),
    do: [port: port, ref: String.to_atom(module_name), timeout: req_timeout()]

  defp req_timeout,
    do: Application.get_env :gateway, :timeout, 5_000

  @doc """
  Dispatch connection.
  """

  @spec dispatch(Plug.Conn.t, param) :: Plug.Conn.t
  def dispatch(conn, _opts) do
    IO.puts "dispatch"
    IO.puts "conn port = #{inspect conn.port}"
    IO.puts "conn request path = #{inspect conn.request_path}"
    conn
    |> target_proxy
    |> Policy.authenticate?(conn.request_path)
    |> IO.inspect

    {:ok, client} =
      conn.method
      |> String.downcase
      |> String.to_atom
      |> HTTPoison.request(uri(conn), "", conn.req_headers,  options())

    # IO.puts "client = #{inspect client}"
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
    # IO.puts "base = #{inspect base}"
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
    # IO.puts "call_proxy"
    # IO.puts "conn = #{inspect conn}"
    # IO.puts "client = #{inspect client}"
    # Logger.debug fn -> "request path: #{gen_path(conn, target_proxy(conn))}" end
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



end
