use Mix.Config

config :snitch_core, ecto_repos: [Snitch.Repo]

import_config "#{Mix.env()}.exs"
