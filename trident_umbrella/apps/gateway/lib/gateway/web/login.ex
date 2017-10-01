defmodule Gateway.Web.Login do
  require Logger
  import Plug.Conn
  alias Plug.Conn
  alias Directory.User
  alias Gateway.Proxy.Handler

  require IEx

  def new_login(conn, options \\ []) do
    IO.puts "new_login, options: #{inspect options}"


    # IEx.pry
    case options[:error] do
      :no_user ->
        options = Keyword.put_new(options, :error_msg , "Not a valid email!")
      :invalid_pw ->
        options = Keyword.put_new(options, :error_msg , "Not a valid password!")
      # msg ->
      #   IO.puts "#########error = #{msg}"
      #   nil
    end

    # need original redirect_back if error
    options = options
    |> Keyword.put_new(:redirect_back, conn.request_path)

    # options = Keyword.put(options, :error_msg, error_msg)

    IO.puts "options = #{inspect options}"

    IO.puts "current dir = #{File.cwd!}"
    IO.puts "new login page, redirect back = #{conn.request_path}"
    page_contents = EEx.eval_file("apps/gateway/lib/gateway/web/templates/new_login.eex", options)

    conn
    |> Plug.Conn.put_resp_content_type("text/html")
    |> Plug.Conn.send_resp(200, page_contents)
    |> Plug.Conn.halt
  end

  def create_session(conn, default_redirect_url) do
    IO.puts "default_redirect_url = #{default_redirect_url} ************"

    case handle_login_request(conn) do
      # new user
      {:ok, user = %User{}, redirect_back} ->
        IO.puts "user found: #{inspect user}"
        IO.puts "redirect_back: #{inspect redirect_back}"
        session_key = Auth.add_session(user.email)
        IO.puts "session_key = #{session_key}"
        redirect_back = redirect_back || "/"

        conn
        |> Plug.Conn.assign(:current_user, user)
        |> Plug.Conn.put_resp_content_type("text/html")
        |> fetch_my_session
        |> Plug.Conn.put_session(:trident_key, session_key)
        |> put_resp_cookie("trident_user", "email=#{user.email}")
        |> Plug.Conn.put_resp_header("location", redirect_back)
        |> Plug.Conn.send_resp(302, "")
        # |> Plug.Conn.halt

      {error, redirect_back} ->
        IO.puts "error = #{inspect error}, redirect_back: #{inspect redirect_back}"
        options = [error: error, redirect_back: redirect_back]
        IO.puts "error options = #{inspect options}"
        IO.puts "******* error = #{inspect error}, redirect_back: #{redirect_back}"
        new_login(conn, options)
    end

  end

  @doc """
  Puts a request cookie.
  """

  #https://github.com/elixir-plug/plug/blob/6baf248a9371bdac664944b334b1961f8e93e820/lib/plug/test.ex
  #

  # @spec put_req_cookie(Conn.t, binary, binary) :: Conn.t
  # def put_req_cookie(conn, key, value) when is_binary(key) and is_binary(value) do
  #   conn = delete_req_cookie(conn, key)
  #   %{conn | req_headers: [{"cookie", "#{key}=#{value}"}|conn.req_headers]}
  # end

  #  @doc """
  #  Deletes a request cookie.
  #  """
  #  @spec delete_req_cookie(Conn.t, binary) :: Conn.t
  #  def delete_req_cookie(%Conn{req_cookies: %Plug.Conn.Unfetched{}} = conn, key)
  #      when is_binary(key) do
  #    key  = "#{key}="
  #    size = byte_size(key)
  #    fun  = &match?({"cookie", value} when binary_part(value, 0, size) == key, &1)
  #    %{conn | req_headers: Enum.reject(conn.req_headers, fun)}
  #  end

  #  def delete_req_cookie(_conn, key) when is_binary(key) do
  #    raise ArgumentError,
  #      message: "cannot put/delete request cookies after cookies were fetched"
  #  end

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
    IO.puts "handle_login_request: parse"
    opts = Keyword.put_new(opts, :parsers, [Plug.Parsers.URLENCODED, Plug.Parsers.MULTIPART])
    Plug.Parsers.call(conn, Plug.Parsers.init(opts))
  end

  def validate_login(conn) do
    IO.puts "handle_login_request: validate login"
    IO.puts "params = #{inspect conn.params}"
    login = conn.params["login"]
    email = login["name"]
    password = login["password"]
    redirect_back = login["redirect_back"]

    case Directory.find(email) do
      user = %User{} ->
        case User.authenticate(user, password) do
          true ->
            {:ok, user, redirect_back}
          false ->
            {:no_user, redirect_back}
            # Directory.new_login(conn, :no_user)
        end

      nil ->
        {:no_user, redirect_back}
        # Directory.new_login(conn, :no_user)

    end
  end

  def fetch_my_session(conn) do
    opts = Plug.Session.init(store: :cookie, key: "_trident_session", secret: Handler.valid_secret, signing_salt: "cookie store signing salt")
    conn
    |> Plug.Session.call(opts)
    |> fetch_session
  end


end
