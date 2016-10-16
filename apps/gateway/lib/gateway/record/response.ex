defmodule Gateway.Record.Response do
  @moduledoc false

  alias Gateway.Format
  alias Gateway.Utils.File, as: GatewayFile

  @type request_body :: binary
  @type response_body :: binary

  @spec record?() :: boolean
  def record?(), do: Application.get_env :gateway, :record, false

  @spec record(Plug.Conn.t, request_body, response_body) :: Plug.Conn.t
  def record(conn, req_body, res_body) do
    export_mapping = GatewayFile.get_export_path(conn.port)
    export_body = GatewayFile.get_export_binary_path(conn.port)
    filename = GatewayFile.filename(conn.path_info)

    conn
    |> Format.pretty_json!(req_body, export_body <> "/" <> filename, true)
    |> GatewayFile.export(export_mapping, filename)

    res_body
    |> GatewayFile.export(export_body, filename)

    conn
  end
end
