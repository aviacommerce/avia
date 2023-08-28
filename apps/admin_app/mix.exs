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
      elixir: "~> 1.14.2",
      aliases: aliases(),
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
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
      {:phoenix, "~> 1.7.2", override: true},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.19.5"},
      {:phoenix_live_dashboard, "~> 0.8.1"},
      {:vega_lite, "~> 0.1.6"},
      {:esbuild, "~> 0.5", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.1", runtime: Mix.env() == :dev},
      {:petal_components, "~> 1.4.8"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:phoenix_ecto, "~> 4.4"},
      {:gettext, "~> 0.11"},
      {:csv, "~> 2.0.0"},
      {:elixlsx, "~> 0.1.1"},
      {:plug_cowboy, "~> 2.5"},
      {:snitch_core, "~> 0.0.1", in_umbrella: true},
      {:guardian, "~> 1.0"},
      {:params, "~> 2.2"},
      {:yaml_elixir, "~> 2.1.0"},
      # email
      {:swoosh, "~> 1.7.4"},
      {:phoenix_swoosh, "~> 1.1.0"},
      {:snitch_payments, github: "aviacommerce/avia_payments", branch: "develop"},
      {:pdf_generator, ">=0.3.7"},
      {:jason, "~> 1.1"},

      # import from store
      {:oauther, "~> 1.1"},
      {:honeydew, "~> 1.5"}
    ]
  end

  defp aliases do
    [
      "assets.deploy": [
        "tailwind default --minify",
        "esbuild default --minify --loader:.js=jsx",
        "phx.digest"
      ]
    ]
  end
end
