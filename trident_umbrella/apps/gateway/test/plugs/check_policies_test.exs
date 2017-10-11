defmodule Gateway.Plugs.CheckPoliciesTest do
  # use Gateway.ConnCase
  use ExUnit.Case, async: true
  use Plug.Test

  require Logger

  alias Gateway.Web.Login
  alias Directory.User

  setup_all do
    Application.put_env(:gateway, :proxies, [%{allow: ["/", "/assets/**"], port: 8085, to: "http://localhost:3000"}])
  end


  test "For a protected route assigns protected_route true" do
    conn = conn(:get, "http://localhost:8085/foo")
    |> Gateway.Plugs.CheckPolicies.call(%{})

    assert conn.assigns[:protected_route] == true
  end

  test "For allowed route assigns protected_route false" do
    conn = conn(:get, "http://localhost:8085/")
    |> Gateway.Plugs.CheckPolicies.call(%{})

    assert conn.assigns[:protected_route] == false
  end

end

