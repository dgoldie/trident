defmodule Gateway.Proxy.HttpAsyncResponse do

  require Logger
  alias Plug.Conn
  alias Plug.Conn.Cookies

  def run(conn, url) do
    method = conn.method |> String.downcase |> String.to_atom

    uri = URI.parse(url)
    base_url = URI.to_string(%URI{scheme: uri.scheme, host: uri.host, port: uri.port})
    options = [ ibrowse: [stream_to: {self(), :once}],
                headers: cookies_list(conn)
              ]

    case HTTPotion.request(method, url, options) do
      %HTTPotion.AsyncResponse{id: id} ->
        async_response(conn, id)

      %HTTPotion.ErrorResponse{message: "retry_later"} ->
        # Logger.info "error:503 retry_later: #{inspect conn}"
        # send_error(conn, "retry_later")
        Plug.Conn.put_status(conn, 503)

      %HTTPotion.ErrorResponse{message: msg} ->
        # Logger.info "error:502 #{msg}: #{inspect conn}"
        # send_error(conn, msg)
        Plug.Conn.put_status(conn, 502)
    end
  end

  defp async_response(conn, id) do
    Logger.info "async_response: id = #{id}, #{conn.request_path}"
    :ok = :ibrowse.stream_next(id)

    receive do
      {:ibrowse_async_headers, ^id, '200', _headers} ->
        Logger.info "async_response:ibrowse_async_headers 200 id = #{id}"
        conn = Plug.Conn.send_chunked(conn, 200)
        # Here you might want to set proper headers to `conn`
        # based on `headers` from a response.
        Logger.info "after send_chunked status code = 200, #{conn.request_path}"

        async_response(conn, id)
      {:ibrowse_async_headers, ^id, status_code, _headers} ->
        Logger.info "async_response:ibrowse_async_headers id = #{id}, #{status_code}"

        {status_code_int, _} = :string.to_integer(status_code)
        # If a service responded with an error, we still need to send
        # this error to a client. Again, you might want to set
        # proper headers based on response.

        conn = Plug.Conn.send_chunked(conn, status_code_int)
        Logger.info "after send_chunked status code = #{status_code_int}, #{conn.request_path}"

        async_response(conn, id)
      {:ibrowse_async_response_timeout, ^id} ->
        Logger.info "async_response:ibrowse_async_response_timeout id = #{id}"

        Plug.Conn.put_status(conn, 408)
      {:error, :connection_closed_no_retry} ->
        Logger.info "async_response:connection_closed_no_retry id = #{id}"

        Plug.Conn.put_status(conn, 502)
      {:ibrowse_async_response, ^id, data} ->
        Logger.info "async_response:ibrowse_async_response: id = #{id}, data = #{inspect data}"
        case Plug.Conn.chunk(conn, data) do
          {:ok, conn} ->
            Logger.info "chunk data: :ok"
            async_response(conn, id)

          {:error, :closed} ->
            Logger.info "chunk data: :error, Client closed connection before receiving the last chunk"
            conn

          {:error, reason} ->
            Logger.info "chunk data: :error, Unexpected error, reason: #{inspect(reason)}"
            conn
        end
      {:ibrowse_async_response_end, ^id} ->
        Logger.info "async_response:ibrowse_async_response_end id = #{id}, #{conn.request_path}"
        conn
    end
  end

  defp to_keyword_list(dict) do
    Enum.map(dict, fn({key, value}) -> {String.to_atom(key), value} end)
  end

  defp cookies_list(conn) do
    conn = conn |> Conn.fetch_cookies
    cookie_list = conn.cookies |> to_keyword_list
    IO.puts "conn cookie_list = #{inspect cookie_list}"

    cookie_list
    |> Enum.map(fn {k,v} -> Cookies.encode(k, %{value: v}) end)
    |> Enum.map(fn value -> [cookie: value] end)
    |> List.flatten
  end
end
