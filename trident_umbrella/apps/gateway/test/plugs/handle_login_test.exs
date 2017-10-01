defmodule Gateway.Plugs.HandleLoginTest do
  # use Gateway.ConnCase
  use ExUnit.Case, async: true
  use Plug.Test

  require Logger
  alias Gateway.Proxy.Handler


  alias Directory.User

  setup_all do
    user_attrs = %{email: "moe@tri.com", first_name: "Moe", last_name: "Howard", password: "abc"}
    user = User.create(user_attrs)
    Directory.add_user(user)

    login_attrs = [login: [name: "moe@tri.com", password: "abc"]]
    conn = conn(:post, "/login", login_attrs)
    |> handle_login

    {:ok, user: user, conn: conn}
  end

  test "redirects when valid user", state do
    conn = state[:conn]
    assert conn.status == 302
  end

  test "current user is added for login with valid params", state do
    user = state[:user]
    conn = state[:conn]
    assert conn.assigns[:current_user] == user
    assert conn.status == 302
  end

  defp handle_login(conn) do
    conn
    |> Handler.put_secret_key_base(nil)
    |> Gateway.Plug.HandleLogin.call(%{create_session_url: "/login"})
  end
end
