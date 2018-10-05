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
  render_errors: [view: AdminAppWeb.ErrorView, accepts: ~w(html json json-api)],
  pubsub: [name: AdminApp.PubSub, adapter: Phoenix.PubSub.PG2],
  token_maximum_age: System.get_env("TOKEN_MAXIMUM_AGE"),
  sendgrid_sender_mail: System.get_env("SENDGRID_SENDER_EMAIL"),
  password_reset_salt: System.get_env("PASSWORD_RESET_SALT"),
  support_url: System.get_env("SUPPORT_URL"),
  support_email: System.get_env("SUPPORT_EMAIL")

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configure Guardian
config :admin_app, AdminAppWeb.Guardian,
  issuer: "admin_app",
  secret_key: "3ZqWoF0Smu2G81Q5f/U0z5etD7nYUkYurLs6FEAm+Mj1kGisPyynEDeR4NcoTY77"

config :admin_app, AdminAppWeb.AuthenticationPipe,
  module: AdminAppWeb.Guardian,
  error_handler: AdminAppWeb.AuthErrorHandler

config :admin_app, AdminAppWeb.Mailer,
  adapter: Swoosh.Adapters.Sendgrid,
  api_key: System.get_env("SENDGRID_API_KEY")

config :pdf_generator, wkhtml_path: System.get_env("WKHTML_PATH")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
