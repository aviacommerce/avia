use Mix.Config

config :snitch_core, ecto_repos: [Snitch.Repo]
config :ecto, :json_library, Jason

config :arc,
  bucket: {:system, "BUCKET_NAME"},
  virtual_host: true

config :ex_aws,
  access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, :instance_role],
  secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, :instance_role],
  s3: [
    region: System.get_env("AWS_REGION")
  ]

config :snitch_core, Snitch.Tools.Mailer,
  adapter: Bamboo.SendGridAdapter,
  api_key: System.get_env("SENDGRID_API_KEY"),
  sendgrid_sender_mail: System.get_env("SENDGRID_SENDER_EMAIL")

import_config "#{Mix.env()}.exs"
