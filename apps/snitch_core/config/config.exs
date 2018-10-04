use Mix.Config

config :snitch_core, ecto_repos: [Snitch.Repo]
config :ecto, :json_library, Jason

config :arc,
  bucket: {:system, "BUCKET_NAME"},
  virtual_host: true

config :snitch_core, Snitch.BaseUrl,
  frontend_url: System.get_env("FRONTEND_URL"),
  backend_url: System.get_env("BACKEND_URL")

config :snitch_core, Snitch.Tools.Mailer,
  adapter: Bamboo.SendGridAdapter,
  api_key: System.get_env("SENDGRID_API_KEY"),
  sendgrid_sender_mail: System.get_env("SENDGRID_SENDER_EMAIL")

import_config "#{Mix.env()}.exs"
