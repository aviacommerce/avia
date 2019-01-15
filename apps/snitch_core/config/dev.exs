use Mix.Config

# Configure your database
config :snitch_core, Snitch.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "snitch_dev",
  hostname: System.get_env("DB_HOST"),
  pool_size: 10

config :snitch_core, :defaults_module, Snitch.Tools.Defaults
config :arc, storage: Arc.Storage.Local
config :snitch_core, :user_config_module, Snitch.Tools.UserConfig

# TODO: Remove this hack when we set up the config system
config :snitch_core, :defaults, currency: :USD
