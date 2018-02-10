use Mix.Config

# Configure your database
config :core, Core.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "core_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
