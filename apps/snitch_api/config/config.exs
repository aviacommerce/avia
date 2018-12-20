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
config :ja_serializer,
  key_format: :underscored,
  page_key: "page",
  page_number_key: "offset",
  page_size_key: "limit",
  page_number_origin: 1,
  page_size: 2

config :snitch_api, SnitchApi.Guardian,
  issuer: "snitch_api",
  secret_key: "V4h+IQskKPefHzO58nDlKRz/ZAWZ1KpM2PBt0Tp3ozexHDE8JQ4dkwblH7PZvZOm"

config :snitch_api, frontend_checkout_url: System.get_env("FRONTEND_CHECKOUT_URL")
config :snitch_api, hosted_payment_url: System.get_env("HOSTED_PAYMENT_URL")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
