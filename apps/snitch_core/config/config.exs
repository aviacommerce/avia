use Mix.Config

config :snitch_core, ecto_repos: [Snitch.Repo]
config :worldly, :data_path, Path.join(Mix.Project.build_path(), "lib/worldly/priv/data")

import_config "#{Mix.env()}.exs"
