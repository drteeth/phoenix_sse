defmodule PhoenixSseWeb.PageController do
  use PhoenixSseWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def sse(conn, params) do
    conn =
      conn
      |> put_resp_content_type("text/event-stream")
      |> put_resp_header("cache-control", "no-cache")
      # |> put_resp_header("Connection", "keep-alive") # only in http/1
      |> send_chunked(200)

    Process.send_after(self(), {:msg, "HELLO 1"}, 1_000)
    Process.send_after(self(), {:msg, "HELLO 2"}, 2_000)
    Process.send_after(self(), {:msg, "HELLO 3"}, 3_000)
    Process.send_after(self(), {:msg, "HELLO 4"}, 4_000)
    Process.send_after(self(), {:msg, "HELLO 5"}, 5_000)
    Process.send_after(self(), {:msg, "HELLO 6"}, 45_000)

    last_event_id =
      with [id_str] <- get_req_header(conn, "last-event-id"),
           {id, ""} <- Integer.parse(id_str) do
        id
      else
        _ -> -1
      end

    loop(conn, last_event_id + 1)
  end

  @keep_alive ":ping\n\n"

  def loop(conn, id) do
    receive do
      {:msg, data} ->
        IO.inspect(data, label: "data")

        case(chunk(conn, "id: #{id}\ndata: #{data}\n\n")) do
          {:ok, conn} ->
            loop(conn, id + 1)

          {:error, :close} ->
            IO.inspect("closed receiving")
            conn
        end
    after
      30_000 ->
        case(chunk(conn, @keep_alive)) do
          {:ok, conn} ->
            IO.puts("keep-alive")
            loop(conn, id)

          {:error, :closed} ->
            IO.inspect("closed keeping alive")
            conn
        end
    end
  end
end
