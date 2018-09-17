use Mix.Config

import_config "prod.secret.exs"

config :snitch_core, :defaults_module, Snitch.Tools.Defaults
config :snitch_core, :user_config_module, Snitch.Tools.UserConfig
config :arc, storage: Arc.Storage.S3
