defmodule Gateway.Plugs.AuthenticateSessionTest do
  # use Gateway.ConnCase
  use ExUnit.Case, async: true
  use Plug.Test

  require Logger

  alias Gateway.Web.Login
  alias Directory.User

  setup_all do
    user_attrs = %{email: "moe@tri.com", first_name: "Moe", last_name: "Howard", password: "abc"}
    user = User.create(user_attrs)
    Directory.add_user(user)

    session_key = Auth.add_session(user.email)

    conn = conn(:get, "/foo")
    |> Login.fetch_my_session
    |> put_session(:trident_key, session_key)
    |> Gateway.Plugs.AuthenticateSession.call(%{})

    {:ok, user: user, conn: conn}
  end


  test "current user is added", state do
    user = state[:user]
    conn = state[:conn]
    assert conn.assigns[:current_user] == user
  end

end
