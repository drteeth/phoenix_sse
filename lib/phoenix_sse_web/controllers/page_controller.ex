defmodule PhoenixSseWeb.PageController do
  use PhoenixSseWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def data(conn, _params) do
    conn =
      conn
      |> put_resp_content_type("text/event-stream")
      |> put_resp_header("Cache-Control", "no-cache")
      |> put_resp_header("Connection", "keep-alive")
      |> send_chunked(200)

    with {:ok, conn} <- chunk(conn, "event:message\ndata:first\n\n"),
         {:ok, conn} <- chunk(conn, "event:message\ndata:first\n\n") do
      conn
    end
  end
end
