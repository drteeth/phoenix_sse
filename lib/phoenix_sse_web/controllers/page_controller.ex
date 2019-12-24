defmodule PhoenixSseWeb.PageController do
  use PhoenixSseWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
