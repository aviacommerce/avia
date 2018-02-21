use Mix.Config

config :core, ecto_repos: [Core.Repo]
config :worldly, :data_path, Path.join(Mix.Project.build_path(), "lib/worldly/priv/data")
import_config "#{Mix.env()}.exs"
