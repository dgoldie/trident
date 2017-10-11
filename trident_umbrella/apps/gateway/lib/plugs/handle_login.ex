defmodule Gateway.Plugs.HandleLogin do
  @moduledoc """
  HandleLogin processes login POST:
    - validates user info in Directory
    - creates token in Auth
    - adds token in session.

  NOTE: should it also add session?
  """

  import Plug.Conn

  require Logger

  alias Gateway.Proxy.Handler
  alias Gateway.Web

  # alias Plug.Conn
  alias Directory.User


  def init(options), do: options

  def call(%Plug.Conn{request_path: path} = conn, opts) do
    IO.puts "call *******"
    Logger.debug fn -> "-------Plug HandleLogin: ---------------" end
    Handler.check_cookies(conn)

    Logger.debug fn -> ".......request path = #{path}, method: #{conn.method}" end
    IO.puts "opts = #{inspect opts}"
    if path == opts[:create_session_url] do
      Logger.debug fn -> "-------Plug HandleLogin: is create session url" end

      conn = Web.Login.create_session(conn, Handler.target_proxy(conn)[:to])

    end

    IO.puts "after create session"
    Handler.check_cookies(conn)
    conn
  end

  # defp target_proxy(conn) do
  #   proxies()
  #   |> Enum.reduce([], fn proxy, acc ->
  #     if proxy.port == conn.port, do: [proxy | acc], else: acc
  #   end)
  #   |> Enum.at(0)
  # end

  # @spec proxies() :: []
  # def proxies,
  #   do: Application.get_env :gateway, :proxies, nil

  # def create_session(conn, default_redirect_url) do
  #   IO.puts "HandleLogin: default_redirect_url = #{default_redirect_url} ************"

  #   case handle_login_request(conn) do
  #     # new user
  #     {:ok, user = %User{}, redirect_back} ->
  #       IO.puts "user found: #{inspect user}"
  #       IO.puts "redirect_back: #{inspect redirect_back}"
  #       session_key = Auth.add_session(user.email)
  #       IO.puts "session_key = #{session_key}"

  #       conn
  #       |> Plug.Conn.put_resp_content_type("text/html")
  #       |> fetch_my_session
  #       |> Plug.Conn.put_session(:trident_key, session_key)
  #       |> put_resp_cookie("trident_user", "email=#{user.email}")
  #       |> Plug.Conn.put_resp_header("location", redirect_back)
  #       |> Plug.Conn.send_resp(302, "")
  #       |> Plug.Conn.halt

  #     {:error, msg} ->
  #       IO.puts "******* error: msg = #{inspect msg}"
  #       Web.Login.new_login(conn, msg)
  #   end

  # end

  # def handle_login_request(conn) do
  #   IO.puts "HandleLogin: handle_login_request"

  #   cond do
  #     conn.request_path != "/login" -> conn
  #     true ->
  #       conn
  #       |> parse
  #       |> validate_login
  #   end

  # end

  # def parse(conn, opts \\ []) do
  #   IO.puts "HandleLogin: parse"
  #   opts = Keyword.put_new(opts, :parsers, [Plug.Parsers.URLENCODED, Plug.Parsers.MULTIPART])
  #   Plug.Parsers.call(conn, Plug.Parsers.init(opts))
  # end

  # def validate_login(conn) do
  #   IO.puts "HandleLogin: validate login"
  #   IO.inspect conn.params
  #   login = conn.params["login"]
  #   email = login["name"]
  #   password = login["password"]
  #   redirect_back = login["redirect_back"]

  #   case Directory.find(email) do
  #     user = %User{} ->
  #       case User.authenticate(user, password) do
  #         true ->
  #           {:ok, user, redirect_back}
  #         false ->
  #           {:error, :no_user}
  #           # Directory.new_login(conn, :no_user)
  #       end

  #     nil ->
  #       {:error, :no_user}
  #       # Directory.new_login(conn, :no_user)

  #   end
  # end

  # def fetch_my_session(conn) do
  #   opts = Plug.Session.init(store: :cookie, key: "_trident_session", secret: Handler.valid_secret, signing_salt: "cookie store signing salt")
  #   conn
  #   |> Plug.Session.call(opts)
  #   |> fetch_session
  # end


end
