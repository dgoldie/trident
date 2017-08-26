defmodule TridentWeb.PageController do
  use TridentWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
