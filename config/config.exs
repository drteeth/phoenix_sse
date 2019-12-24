# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :phoenix_sse,
  ecto_repos: [PhoenixSse.Repo]

# Configures the endpoint
config :phoenix_sse, PhoenixSseWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "rDtVzORPoRoQGbfn4VUUEkWIYGRg7sPj7asb0y0fxg1zZlU9eKrTpymVvYwgYsLW",
  render_errors: [view: PhoenixSseWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: PhoenixSse.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :mime, :types, %{
  "text/event-stream" => ["sse"]
}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
