defmodule PhoenixSseWeb.PageController do
  use PhoenixSseWeb, :controller

  alias PhoenixSseWeb.SSE
  alias PhoenixSse.StockTicker

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def sse(conn, _params) do
    # If this is a re-connect, it will include the ID
    # of the last event seen by the client which we
    # can use to determine what to show them next.
    last_event_id = get_last_event_id(conn)

    # Block and listen for ticker updates
    conn
    |> SSE.listen(StockTicker.topic(), last_event_id)
  end

  def add_symbol(conn, params) do
    StockTicker.add_symbol(params["symbol"])

    conn
    |> put_status(:ok)
    |> json(%{ok: true})
  end

  @spec get_last_event_id(Plug.Conn.t()) :: String.t() | nil
  defp get_last_event_id(conn) do
    conn
    |> get_req_header("last-event-id")
    |> List.first()
  end
end
