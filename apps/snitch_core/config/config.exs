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

config :snitch_core, Snitch.Tools.Mailer,
  adapter: Bamboo.SendGridAdapter,
  api_key: System.get_env("SENDGRID_API_KEY")

config :snitch_core, Rummage.Ecto,
  default_repo: Snitch.Repo,
  default_per_page: 2

config :triplex,
  repo: Snitch.Repo,
  reserved_tenants: ["www", "api", "demo", "admin"],
  migrations_path: "migrations"

config :snitch_core, Snitch.Tools.ElasticsearchCluster,
  url: System.get_env("ELASTIC_HOST"),
  # username: "username",
  # password: "password",
  api: Elasticsearch.API.HTTP,
  json_library: Poison,
  indexes: %{
    products: %{
      settings: "priv/elasticsearch/products.json",
      store: Snitch.Tools.ElasticSearch.Product.Store,
      sources: [Snitch.Data.Schema.Product],
      bulk_page_size: 5000,
      bulk_wait_interval: 15_000
    }
  }

import_config "#{Mix.env()}.exs"
