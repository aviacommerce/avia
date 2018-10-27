defmodule AdminApp.Mixfile do
  use Mix.Project

  def project do
    [
      app: :admin_app,
      version: "0.0.1",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.7.2",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {AdminApp.Application, []},
      extra_applications: [:logger, :runtime_tools, :pdf_generator, :sentry]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.3.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:phoenix_ecto, "~> 3.0"},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:snitch_core, "~> 0.0.1", in_umbrella: true},
      {:guardian, "~> 1.0"},
      {:params, "~> 2.0"},
      {:yaml_elixir, "~> 2.1.0"},
      # email
      {:swoosh, "~> 0.15"},
      {:phoenix_swoosh, "~> 0.2"},
      {:gen_smtp, "~> 0.12"},
      {:snitch_payments, github: "aviacommerce/avia_payments", branch: "develop"},
      {:pdf_generator, ">=0.3.7"},
      {:sentry, "~> 7.0"},
      {:jason, "~> 1.1"},

      # import from store
      {:oauther, "~> 1.1"},
      {:honeydew, "~> 1.2.6"}
    ]
  end
end
