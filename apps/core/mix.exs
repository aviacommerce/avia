defmodule Core.Mixfile do
  use Mix.Project

  def project do
    [
      app: :core,
      version: "0.0.1",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.detail": :test, "coveralls.html": :test]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Core.Application, []},
      extra_applications: [:logger, :runtime_tools, :yamerl, :worldly]
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
      {:postgrex, "~> 0.13.5"},
      {:ecto, "~> 2.1"},
      {:poison, "~> 3.1", override: true},
      {:ex_money, "~> 2.2.0"},
      {:credo, "~> 0.8.10", only: :dev, runtime: false},

      # auth
      {:comeonin, "~> 4.0"},
      {:argon2_elixir, "~> 1.2"},

      # docs and tests
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:excoveralls, "~> 0.8", only: :test},
      {:ex_machina, "~> 2.1", only: :test},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:excountries, "~> 0.0.1"},
      {:yamerl, github: "yakaz/yamerl", override: true},
      {:worldly, github: "martide/worldly"},
      {:uuid, "~> 1.1"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
