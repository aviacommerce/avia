use Mix.Config

config :core, ecto_repos: [Core.Repo]

import_config "#{Mix.env}.exs"
