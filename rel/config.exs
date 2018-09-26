# Import all plugins from `rel/plugins`
# They can then be used by adding `plugin MyPlugin` to
# either an environment, or release definition, where
# `MyPlugin` is the name of the plugin module.
~w(rel plugins *.exs)
|> Path.join()
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
    # This sets the default release built by `mix release`
    default_release: :default,
    # This sets the default environment used by `mix release`
    default_environment: Mix.env()

# For a full list of config options for both releases
# and environments, visit https://hexdocs.pm/distillery/config/distillery.html


# You may define one or more environments in this file,
# an environment's settings will override those of a release
# when building in that environment, this combination of release
# and environment configuration is called a profile

environment :dev do
  # If you are running Phoenix, you should make sure that
  # server: true is set and the code reloader is disabled,
  # even in dev mode.
  # It is recommended that you build with MIX_ENV=prod and pass
  # the --env flag to Distillery explicitly if you want to use
  # dev mode.
  set dev_mode: true
  set include_erts: false
  set cookie: :"a]W7Kkh~35[}P&we8Vk!pppF!af;XH>82J8Wxep*GH@l!.]9qz341}ncHx3;i%5:"
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"jZbqQZT/2bBKHZVuGpE~F$eQrG/N0.W1>3p4L$Pw|m%pQAm/:iSl3Gt~M0YuXaE<"
end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix release`, the first release in the file
# will be used by default

release :snitch do
  set version: current_version(:snitch_api)
  set applications: [
    :runtime_tools,
    admin_app: :permanent,
    help: :permanent,
    snitch_api: :permanent,
    snitch_core: :permanent
  ]
  set commands: [
    seed: "rel/commands/seed.sh",
  ]
  set pre_start_hooks: "rel/hooks/pre_start"
  set post_start_hooks: "rel/hooks/post_start"
end

