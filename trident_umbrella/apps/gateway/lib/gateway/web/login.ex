defmodule Gateway.Web.Login do
  require IEx
  import Plug.Conn
  alias Directory.User
  alias Gateway.Proxy.Handler

  def new_login(conn, error \\ []) do
    IO.puts "new_login, error: #{error}"
    options = [redirect_back: conn.request_path]

    case error do
      :no_user -> options.merge(%{error_msg: "Not a valid email!"})
      :invalid_pw -> options.merge(%{error_msg: "Not a valid password!"})
      _ -> nil
    end

    IO.puts "options = #{inspect options}"

    IO.puts "current dir = #{File.cwd!}"
    IO.puts "new login, request_path = #{conn.request_path}"
    page_contents = EEx.eval_file("apps/gateway/lib/gateway/web/templates/new_login.eex", options)
    # IEx.pry

    conn
    |> Plug.Conn.put_resp_content_type("text/html")
    |> Plug.Conn.send_resp(200, page_contents)
  end

  def create_session(conn, redirect_url) do
    IO.puts "create session"
    case handle_login_request(conn) do
      # new user
      user = %User{} ->
        IO.puts "user found: #{inspect user}"
        session_key = Auth.add_session(user.email)
        IO.puts "session_key = #{session_key}"

        conn
        |> Plug.Conn.put_resp_content_type("text/html")
        # |> Plug.Conn.put_resp_header("trident_session", session_key)
        |> fetch_my_session
        |> Plug.Conn.put_session(:trident_key, session_key)
        |> Plug.Conn.put_resp_header("location", "/")
        |> Plug.Conn.send_resp(302, "")

      nil ->

        IO.puts "no user"
        new_login(conn, :no_user)
    end

  end

  def handle_login_request(conn) do
    IO.puts "handle_login_request"

    cond do
      conn.request_path != "/login" -> conn
      true ->
        conn
        |> parse
        |> validate_login
    end

  end

  def parse(conn, opts \\ []) do
    opts = Keyword.put_new(opts, :parsers, [Plug.Parsers.URLENCODED, Plug.Parsers.MULTIPART])
    Plug.Parsers.call(conn, Plug.Parsers.init(opts))
  end

  def validate_login(conn) do
    IO.puts "validate login"
    IO.inspect conn.params
    login = conn.params["login"]
    email = login["name"]
    password = login["password"]
    redirect_back = login["redirect_back"]

    case Directory.find(email) do
      user = %User{} ->
        case User.authenticate(user, password) do
          true -> user
          false -> Directory.new_login(conn, :no_user)
        end

      nil ->
        Directory.new_login(conn, :no_user)
    end
  end

  def fetch_my_session(conn) do
    opts = Plug.Session.init(store: :cookie, key: "_trident_session", secret: Handler.valid_secret, signing_salt: "cookie store signing salt")
    conn
    |> Plug.Session.call(opts)
    |> fetch_session
  end


end
