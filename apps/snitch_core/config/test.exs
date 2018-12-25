use Mix.Config

# Configure your database
config :snitch_core, Snitch.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "snitch_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :snitch_core, :defaults_module, Snitch.Tools.DefaultsMock
config :snitch_core, :user_config_module, Snitch.Tools.UserConfigMock
config :arc, storage: Arc.Storage.Local

config :snitch_core, Snitch.Tools.Mailer, adapter: Bamboo.TestAdapter

config :snitch_core, :defaults, currency: :USD
config :logger, level: :info

config :argon2_elixir,
  t_cost: 1,
  m_cost: 8

config :snitch_core, Snitch.Tools.ElasticsearchCluster,
  url: "http://localhost:9200",
  # username: "username",
  # password: "password",
  api: Elasticsearch.API.HTTP,
  json_library: Poison,
  indexes: %{
    products_test: %{
      settings: "priv/elasticsearch/products.json",
      store: Snitch.Tools.ElasticSearch.ProductStore,
      sources: [Snitch.Data.Schema.Product],
      bulk_page_size: 5000,
      bulk_wait_interval: 15_000
    }
  }
