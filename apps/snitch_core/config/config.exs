use Mix.Config

config :snitch_core, ecto_repos: [Snitch.Repo]
config :ecto, :json_library, Jason

config :arc,
  bucket: {:system, "BUCKET_NAME"},
  virtual_host: true

config :snitch_core, Snitch.BaseUrl,
  frontend_url: System.get_env("FRONTEND_URL"),
  backend_url: System.get_env("BACKEND_URL")

config :ex_aws,
  access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, :instance_role],
  secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, :instance_role],
  s3: [
    region: System.get_env("AWS_REGION")
  ]

config :snitch_core, Snitch.Tools.Mailer, adapter: Bamboo.SendGridAdapter

config :snitch_core, Rummage.Ecto,
  default_repo: Snitch.Repo,
  default_per_page: 2

import_config "#{Mix.env()}.exs"
