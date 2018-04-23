# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :admin_app, namespace: AdminApp

# Configures the endpoint
config :admin_app, AdminAppWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "o7U+x3aM3mqN1vY+PGIbxEN+QBeMP7rwgCpyrbYfEUkAY6I12cxKvwEt/zJeGjgR",
  render_errors: [view: AdminAppWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: AdminApp.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
