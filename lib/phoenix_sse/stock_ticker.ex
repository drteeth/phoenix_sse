defmodule PhoenixSse.StockTicker do
  use GenServer

  defmodule State do
    defstruct events: [], symbols: ["ABCD"]
  end

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %State{}, name: __MODULE__)
  end

  @impl GenServer
  def init(state) do
    {:ok, state, {:continue, :schedule_next_tick}}
  end

  def topic() do
    "stocks"
  end

  def resend_since(id) do
    GenServer.call(__MODULE__, {:resend_since, id})
  end

  def add_symbol(symbol) do
    GenServer.call(__MODULE__, {:add_symbol, symbol})
  end

  @impl GenServer
  def handle_continue(:schedule_next_tick, state) do
    schedule_next_tick()
    {:noreply, state}
  end

  @impl GenServer
  def handle_call({:resend_since, id}, {pid, _ref}, state) do
    IO.inspect(id, label: "resend_since")

    state.events
    |> Enum.drop(id + 1)
    |> IO.inspect(label: "missed")
    |> Enum.each(fn event ->
      if Process.alive?(pid) do
        send(pid, %{topic: topic(), event: "update", payload: event})
      end
    end)

    {:reply, :ok, state}
  end

  @impl GenServer
  def handle_call({:add_symbol, symbol}, _from, state) do
    id = state.events |> Enum.count()

    event =
      publish_event(%{
        id: id,
        symbol: symbol,
        value: 0
      })

    state = %{state | symbols: [symbol | state.symbols], events: state.events ++ [event]}

    {:reply, :ok, state}
  end

  @impl GenServer
  def handle_info({:tick, value}, state) do
    id = state.events |> Enum.count()
    symbol = state.symbols |> Enum.random()

    stock = %{
      id: id,
      symbol: symbol,
      value: value
    }

    event = publish_event(stock)

    state = %{state | events: state.events ++ [event]}

    schedule_next_tick()

    {:noreply, state}
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
