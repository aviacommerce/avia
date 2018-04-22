use Mix.Config

import_config "prod.secret.exs"

config :snitch_core, :defaults_module, Snitch.Tools.Defaults
