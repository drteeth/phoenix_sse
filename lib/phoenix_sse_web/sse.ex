defmodule PhoenixSseWeb.SSE do
  @keep_alive ":ping\n\n"

  @spec listen(Plug.Conn.t(), String.t(), String.t() | nil) :: Plug.Conn.t()
  def listen(conn, topic, last_event_id) do
    last_id = parse_event_id(last_event_id)

    conn = conn |> put_sse_headers()

    # re-send any events we've missed
    PhoenixSse.StockTicker.resend_since(last_id)

    # listen for new events
    PhoenixSseWeb.Endpoint.subscribe(topic)

    # Start the receive loop
    loop(topic, conn)
  end

  @spec put_sse_headers(Plug.Conn.t()) :: Plug.Conn.t()
  def put_sse_headers(conn) do
    conn
    |> Plug.Conn.put_resp_content_type("text/event-stream")
    |> Plug.Conn.put_resp_header("cache-control", "no-cache")
    # ONLY HTTP 1.1 ! |> Plug.Conn.put_resp_header("Connection", "keep-alive")
    |> Plug.Conn.send_chunked(200)
  end

  @spec loop(String.t(), Plug.Conn.t()) :: Plug.Conn.t()
  def loop(topic, conn) do
    receive do
      %{topic: ^topic, event: "update", payload: event} ->
        # We've got a message, send it to the client
        case(Plug.Conn.chunk(conn, "id: #{event.id}\ndata: #{Jason.encode!(event)}\n\n")) do
          {:ok, conn} ->
            IO.inspect(event, label: "sent SSE message")
            loop(topic, conn)

          {:error, :close} ->
            IO.inspect("connection closed.")
            conn
        end
    after
      30_000 ->
        # We haven't sent anything to the client lately, ping them to keep the connection alive
        case(Plug.Conn.chunk(conn, @keep_alive)) do
          {:ok, conn} ->
            IO.puts("keep-alive")
            loop(topic, conn)

          {:error, :closed} ->
            IO.inspect("closed keeping alive")
            conn
        end
    end
  end

  @spec parse_event_id(String.t() | nil) :: integer
  defp parse_event_id(id_str) do
    case id_str do
      nil -> -1
      id -> String.to_integer(id)
    end
  end
end
