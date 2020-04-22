defmodule PhoenixSse.SSEEncoder do
  @spec encode(Keyword.t()) :: String.t()
  def encode(opts \\ []) do
    {:ok, io} = StringIO.open("")

    io
    |> write("id: ", Keyword.get(opts, :id))
    |> write("data: ", Keyword.get(opts, :data))
    |> write("event: ", Keyword.get(opts, :event))
    |> write(":", Keyword.get(opts, :comment))
    |> flush()
  end

  @spec write(pid, String.t() | nil, String.t() | nil) :: pid
  defp write(io, _, nil), do: io

  defp write(io, prefix, body) do
    IO.write(io, prefix)
    IO.write(io, body)
    IO.write(io, "\n")
    io
  end

  @spec flush(pid) :: String.t()
  defp flush(io) do
    IO.write(io, "\n")
    StringIO.flush(io)
  end
end
