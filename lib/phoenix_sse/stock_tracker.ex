defmodule PhoenixSse.StockTracker do
  defstruct events: [], symbols: []

  alias __MODULE__, as: StockTracker
  alias PhoenixSse.StockEvent

  @spec new(list(String.t())) :: StockTracker.t()
  def new(symbols) do
    %StockTracker{symbols: symbols}
  end

  @spec resend_events_after(StockTracker.t(), non_neg_integer(), to: pid()) :: :ok
  def resend_events_after(tracker, last_read, to: pid) do
    tracker.events
    |> Enum.drop(last_read + 1)
    |> Enum.each(fn event ->
      notify_one(pid, event)
    end)
  end

  @spec add_symbol(StockTracker.t(), String.t()) :: StockTracker.t()
  def add_symbol(tracker, symbol) do
    event = %StockEvent{
      id: next_id(tracker),
      symbol: symbol,
      value: 0
    }

    notify_all(event)

    %{
      tracker
      | symbols: [symbol | tracker.symbols],
        events: tracker.events ++ [event]
    }
  end

  @spec update_random_symbol(StockTracker.t(), non_neg_integer()) :: StockTracker.t()
  def update_random_symbol(tracker, value) do
    symbol = tracker.symbols |> Enum.random()

    event = %StockEvent{
      id: next_id(tracker),
      symbol: symbol,
      value: value
    }

    notify_all(event)

    %{tracker | events: tracker.events ++ [event]}
  end

  @spec topic() :: String.t()
  def topic() do
    "stocks"
  end

  @spec notify_one(pid(), Stock.t()) :: :ok | {:error, :undeliverable}
  defp notify_one(pid, event) do
    if Process.alive?(pid) do
      send(pid, %{topic: topic(), event: "update", payload: event})
      :ok
    else
      {:error, :undeliverable}
    end
  end

  @spec notify_all(Stock.t()) :: :ok | {:error, any}
  defp notify_all(event) do
    PhoenixSseWeb.Endpoint.broadcast(topic(), "update", event)
  end

  @spec next_id(StockTracker.t()) :: non_neg_integer()
  defp next_id(tracker) do
    tracker.events |> Enum.count()
  end
end
