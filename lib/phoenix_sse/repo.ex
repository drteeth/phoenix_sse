defmodule PhoenixSse.Repo do
  use Ecto.Repo,
    otp_app: :phoenix_sse,
    adapter: Ecto.Adapters.Postgres
end
