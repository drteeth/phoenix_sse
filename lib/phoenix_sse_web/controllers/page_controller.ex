defmodule PhoenixSseWeb.PageController do
  use PhoenixSseWeb, :controller

  alias PhoenixSseWeb.SSE
  alias PhoenixSse.StockTicker

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def sse(conn, _params) do
    # STEP 1: send a response to the clent saying we're
    # doing SSEs and they should expect more data to come 
    # so keep the connection open
    conn =
      conn
      |> put_resp_content_type("text/event-stream")
      |> put_resp_header("cache-control", "no-cache")
      |> put_resp_header("Connection", "keep-alive")
      |> send_chunked(200)

    # If this is a re-connect, it will include the ID
    # of the last event seen by the client which we
    # can use to determine what to show them next.
    last_event_id =
      conn
      |> get_req_header("last-event-id")
      |> List.first()

    IO.inspect(last_event_id, label: "last_event_id")

    # Block here and listen for ticker updates
    conn
    |> SSE.listen(StockTicker.topic(), last_event_id)
  end

  def inject_stock(conn, params) do
    StockTicker.inject(params["symbol"])

    conn
    |> put_status(:ok)
    |> json(%{ok: true})
  end
end
