defmodule PhoenixSse.StockTicker do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(events) do
    schedule_next_tick()
    {:ok, events}
  end

  def topic() do
    "stocks"
  end

  def resend_since(id) do
    GenServer.call(__MODULE__, {:resend_since, id})
  end

  def handle_call({:resend_since, id}, {pid, _ref}, events) do
    IO.inspect(id, label: "resend_since")

    events
    |> Enum.drop(id + 1)
    |> IO.inspect(label: "missed")
    |> Enum.each(fn event ->
      if Process.alive?(pid) do
        send(pid, %{topic: topic(), event: "update", payload: event})
      end
    end)

    {:reply, :ok, events}
  end

  def handle_info({:tick, value}, events) do
    id = Enum.count(events)
    event = publish_event(%{id: id, symbol: "ABCD", value: value})

    schedule_next_tick()

    {:noreply, events ++ [event]}
  end

  def schedule_next_tick() do
    time = :rand.uniform(5_000)
    IO.inspect(time, label: "next_tick")
    Process.send_after(self(), {:tick, time / 10}, time)
  end

  def publish_event(event) do
    PhoenixSseWeb.Endpoint.broadcast(topic(), "update", event)
    event
  end
end
