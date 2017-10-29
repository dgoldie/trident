defmodule Gateway.Plugs.Proxy do
  @moduledoc """
  Documentation for Proxy plug
  """

  require Logger
  alias Gateway.Proxy.Handler
  alias Gateway.Proxy.HttpAsyncResponse
  # alias Gateway.Web
  import Plug.Conn


  def init(options), do: options

  def call(%Plug.Conn{request_path: path} = conn, opts) do

    conn = Handler.add_user_info_cookie(conn)
    # Handler.check_cookies(conn)


    client = HttpAsyncResponse.run(conn, Handler.uri(conn))
    Logger.info "_____________________Proxy call "
    IO.inspect client
    client
  end

end
