defmodule Gateway.HandleTest do
  use ExUnit.Case, async: true
  use ExUnit.Parameterized
  use Plug.Test

  alias Gateway.Handle, as: GatewayHandle

  doctest Gateway.Data
  doctest Gateway.Handle

  test_with_params "should convert urls",
    fn local_url, proxied_url ->
      conn = conn(:get, local_url)
      assert GatewayHandle.uri(conn) == proxied_url
    end do
      [
        "root":  {"http://localhost:8080/", "http://google.com/" },
        "path":  {"https://localhost:8081/neko", "http://example.com/neko"},
        "query": {"http://localhost:8081/neko?hoge=1", "http://example.com/neko?hoge=1"},
        "no proxy with http":  {"http://localhost:8082/", "http://localhost/" },
        "no proxy with https":  {"https://localhost:8082/", "https://localhost/" },
      ]
  end
end
