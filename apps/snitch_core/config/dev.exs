use Mix.Config

# Configure your database
config :snitch_core, Snitch.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "snitch_dev",
  hostname: "localhost",
  pool_size: 10

config :snitch_core, :defaults_module, Snitch.Tools.Defaults
config :arc, storage: Arc.Storage.Local
config :snitch_core, :user_config_module, Snitch.Tools.UserConfig

# TODO: Remove this hack when we set up the config system
config :snitch_core, :defaults, currency: :USD

config :snitch_core, Snitch.Tools.ElasticsearchCluster,
  url: "http://localhost:9200",
  # username: "username",
  # password: "password",
  api: Elasticsearch.API.HTTP,
  json_library: Poison,
  indexes: %{
    products: %{
      settings: "priv/elasticsearch/products.json",
      store: Snitch.Tools.ElasticSearch.ProductStore,
      sources: [Snitch.Data.Schema.Product],
      bulk_page_size: 5000,
      bulk_wait_interval: 15_000
    }
  }
