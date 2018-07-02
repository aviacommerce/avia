# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :snitch_api, SnitchApiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "VAvkjDkSJ/5nLB4aI+77rZ/PyR3foxuD6u1p1X01M3hpc0MJrRDwRNZ0/ERHfcUb",
  render_errors: [view: SnitchApiWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: SnitchApi.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configures JSON API encoding
config :phoenix, :format_encoders, "json-api": Jason

# Configures JSON API mime type
config :mime, :types, %{
  "application/vnd.api+json" => ["json-api"]
}

# Configures Key Format
config :ja_serializer, key_format: :underscored

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
