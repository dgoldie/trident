defmodule Gateway.Plug.AuthenticateSession do

  require Logger
  # alias Gateway.Policy
  alias Auth
  alias Gateway.Proxy.Handler
  alias Gateway.Web
  import Plug.Conn


  def init(options), do: options

  def call(%Plug.Conn{request_path: path} = conn, opts) do
    Logger.debug fn -> "-------Plug AuthenticateSession: ---------------" end
    Logger.debug fn -> ".......request path = #{path}" end
    IO.puts "opts = #{inspect opts}"


    # protected = Policy.protected_route?(conn)
    # IO.puts "protected? = #{inspect protected}"

    if conn.assigns[:protected_route] do
      Logger.debug fn -> "-------Plug AuthenticateSession: request is protected_route !!!" end

      case authenticate_session(conn, opts) do
        nil  ->
          Logger.debug fn -> "-------Plug AuthenticateSession: authenticate session failed. go to new login page!!!" end
          # Web.Login.new_login(conn)
          new_login(conn)

        email ->
          Logger.debug fn -> "-------Plug AuthenticateSession: authenticated #{email}, need to pass" end
          conn |> assign(:user_email, email)
      end
    end

    conn
  end


  defp authenticate_session(conn, opts) do
    case trident_session(conn, opts) do
      nil -> nil
      conn ->
        Auth.get_session(conn)
    end
  end

  defp trident_session(conn, opts) do
    Logger.debug fn -> "-------Plug AuthenticateSession: get_trident_session - #{conn.request_path}" end

    opts = Plug.Session.init(store: :cookie, key: "_trident_session", secret: Handler.valid_secret(), signing_salt: "cookie store signing salt")
    result = conn
    |> Plug.Session.call(opts)
    |> fetch_session
    |> get_session(:trident_key)
    # |> IO.inspect
    # |> Auth.get_session

    Logger.debug fn -> "get_trident_session result - '#{result}'" end
    result
  end

  def new_login(conn, error \\ []) do
    IO.puts "Plug AuthenticateSession:new_login, error: #{error}"
    options = [redirect_back: conn.request_path]

    case error do
      :no_user ->
        error_msg = "Not a valid email!"
      :invalid_pw ->
        error_msg = "Not a valid password!"
      msg ->
        IO.puts "#########error = #{msg}"
        nil
    end

    options = Keyword.put(options, :error_msg, error_msg)

    IO.puts "options = #{inspect options}"

    IO.puts "Plug AuthenticateSession:current dir = #{File.cwd!}"
    IO.puts "Plug AuthenticateSession: new login page, redirect back = #{conn.request_path}"
    page_contents = EEx.eval_file("apps/gateway/lib/gateway/web/templates/new_login.eex", options)

    conn
    |> Plug.Conn.put_resp_content_type("text/html")
    |> Plug.Conn.send_resp(200, page_contents)
    # |> Plug.Conn.halt
  end

end
