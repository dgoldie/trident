defmodule Gateway.Plug.CheckPolicies do

  require Logger
  alias Gateway.Policy
  alias Gateway.Proxy.Handler
  alias Gateway.Web
  import Plug.Conn


  def init(options), do: options


  # NOTE: perhaps move policy module scode here
  #
  def call(%Plug.Conn{request_path: path} = conn, opts) do
    Logger.debug fn -> "-------Plug CheckPolicies: ---------------" end

    Logger.debug fn -> ".......request path = #{path}" end
    IO.puts "opts = #{inspect opts}"

    conn = assign(conn, :protected_route, Policy.protected_route?(conn))
    IO.puts ".....protected? = #{inspect conn.assigns[:protected_route]}"

    # if Policy.protected_route?(conn) do
    #   Logger.debug fn -> "-------Plug check policies: request is protected_route !!!" end
    #   assign(conn, :protected_route, true)

      # case authenticate_session(conn, opts) do
      #   nil  ->
      #     Logger.debug fn -> "-------Plug check policies: authenticate session failed. go to new login page!!!" end
      #     Web.Login.new_login(conn)

      #   email ->
      #     Logger.debug fn -> "-------Plug check policies: authenticated #{email}, need to pass" end
      #     conn |> assign(:user_email, email)
      # end
    # end

    conn
  end


  # defp authenticate_session(conn, opts) do
  #   Logger.debug fn -> "-------Plug check policies: authenticate session - #{conn.request_path}" end

  #   opts = Plug.Session.init(store: :cookie, key: "_trident_session", secret: Handler.valid_secret(), signing_salt: "cookie store signing salt")
  #   result = conn
  #   |> Plug.Session.call(opts)
  #   |> fetch_session
  #   |> get_session(:trident_key)
  #   |> Auth.get_session

  #   IO.puts "authenticate_session result - '#{result}'"
  #   result
  # end



end
