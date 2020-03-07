defmodule PhoenixSse.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      PhoenixSse.Repo,
      PhoenixSseWeb.Endpoint,
      PhoenixSse.StockTicker
    ]

    opts = [strategy: :one_for_one, name: PhoenixSse.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    PhoenixSseWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
