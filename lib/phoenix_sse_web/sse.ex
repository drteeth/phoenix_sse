defmodule PhoenixSseWeb.SSE do
  @keep_alive ":ping\n\n"
  @keep_alive_timeout 30_000

  alias PhoenixSse.SSEEncoder

  @spec listen(Plug.Conn.t(), String.t(), String.t() | nil) :: Plug.Conn.t()
  def listen(conn, topic, last_event_id) do
    last_id = parse_event_id(last_event_id)

    conn = conn |> put_sse_headers()

    # re-send any events we've missed
    PhoenixSse.StockTicker.resend_since(last_id)

    # listen for new events
    PhoenixSseWeb.Endpoint.subscribe(topic)

    # Start the receive loop
    loop(conn)
  end

  @spec put_sse_headers(Plug.Conn.t()) :: Plug.Conn.t()
  defp put_sse_headers(conn) do
    conn
    |> Plug.Conn.put_resp_content_type("text/event-stream")
    |> Plug.Conn.put_resp_header("cache-control", "no-cache")
    # ONLY HTTP 1.1 ! |> Plug.Conn.put_resp_header("Connection", "keep-alive")
    |> Plug.Conn.send_chunked(200)
  end

  @spec loop(Plug.Conn.t()) :: Plug.Conn.t()
  defp loop(conn) do
    receive do
      %{payload: %{id: id} = event} ->
        send_sse_chunk(conn, id, event)
    after
      @keep_alive_timeout ->
        send_keep_alive(conn)
    end
  end

  @spec send_sse_chunk(Plug.Conn.t(), term, term) :: Plug.Conn.t()
  defp send_sse_chunk(conn, id, event) do
    data = Jason.encode!(event)
    chunk_data = SSEEncoder.encode(id: id, data: data)

    case(Plug.Conn.chunk(conn, chunk_data)) do
      {:ok, conn} ->
        IO.inspect(chunk_data, label: "sent SSE message")
        loop(conn)

      {:error, :close} ->
        IO.inspect("connection closed.")
        conn
    end
  end

  @spec send_keep_alive(Plug.Conn.t()) :: Plug.Conn.t()
  defp send_keep_alive(conn) do
    # We haven't sent anything to the client lately, ping them to keep the connection alive
    case(Plug.Conn.chunk(conn, @keep_alive)) do
      {:ok, conn} ->
        IO.puts("keep-alive")
        loop(conn)

      {:error, :closed} ->
        IO.inspect("Can't send keep-alive")
        conn
    end
  end

  @spec sse_encode(%{id: String.t()}) :: Plug.Conn.t()
  defp sse_encode(event) do
    id = "id: #{event.id}"
    data = "data: #{Jason.encode!(event)}"
    Enum.join("")
  end

  @spec parse_event_id(String.t() | nil) :: integer
  defp parse_event_id(id_str) do
    case id_str do
      nil -> -1
      id -> String.to_integer(id)
    end
  end
end
