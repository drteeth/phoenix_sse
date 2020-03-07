defmodule PhoenixSse.StockTicker do
  use GenServer

  alias PhoenixSse.StockTracker

  def start_link(_args) do
    GenServer.start_link(__MODULE__, StockTracker.new(["ABCD"]), name: __MODULE__)
  end

  def init(tracker) do
    {:ok, tracker, {:continue, :schedule_next_tick}}
  end

  def resend_since(id) do
    GenServer.call(__MODULE__, {:resend_since, id})
  end

  def add_symbol(symbol) do
    GenServer.call(__MODULE__, {:add_symbol, symbol})
  end

  defdelegate topic(), to: StockTracker

  def handle_continue(:schedule_next_tick, tracker) do
    schedule_next_tick()
    {:noreply, tracker}
  end

  def handle_call({:resend_since, id}, {pid, _ref}, tracker) do
    tracker
    |> StockTracker.resend_events_after(id, to: pid)

    {:reply, :ok, tracker}
  end

  def handle_call({:add_symbol, symbol}, _from, tracker) do
    tracker = tracker |> StockTracker.add_symbol(symbol)

    {:reply, :ok, tracker}
  end

  def handle_info({:tick, value}, tracker) do
    tracker = tracker |> StockTracker.update_random_symbol(value)

    schedule_next_tick()

    {:noreply, tracker}
  end

  defp schedule_next_tick() do
    time = :rand.uniform(5_000)
    Process.send_after(self(), {:tick, time / 10}, time)
  end
end
