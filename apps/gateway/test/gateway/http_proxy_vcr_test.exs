defmodule GatewayVerTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  use Plug.Test

  alias Gateway.Handle, as: GatewayHandle

  @tag skip: "make this test flaky other tests"
  test "get request" do
    use_cassette "httpoison_get" do
      con = conn(:get, "http://localhost:8080/")
      :hackney.request :get, GatewayHandle.uri(con), con.req_headers, [], []
    end
  end
end
