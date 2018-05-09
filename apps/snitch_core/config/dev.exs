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
config :snitch_core, :user_config_module, Snitch.Tools.UserConfig
