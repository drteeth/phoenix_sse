defmodule PhoenixSse.StockEvent do
  @derive Jason.Encoder
  defstruct id: 0, value: 0, symbol: nil
end
