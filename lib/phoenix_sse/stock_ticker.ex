defmodule PhoenixSse.StockTicker do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl GenServer
  def init(events) do
    {:ok, events, {:continue, :schedule_next_tick}}
  end

  def topic() do
    "stocks"
  end

  def resend_since(id) do
    GenServer.call(__MODULE__, {:resend_since, id})
  end

  @impl GenServer
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

  @impl GenServer
  def handle_continue(:schedule_next_tick, state) do
    schedule_next_tick()
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:tick, value}, events) do
    id = Enum.count(events)
    event = publish_event(%{id: id, symbol: "ABCD", value: value})

    schedule_next_tick()

    {:noreply, events ++ [event]}
  end

  defp schedule_next_tick() do
    time = :rand.uniform(5_000)
    Process.send_after(self(), {:tick, time / 10}, time)
  end

  defp publish_event(event) do
    PhoenixSseWeb.Endpoint.broadcast(topic(), "update", event)
    event
  end
end
