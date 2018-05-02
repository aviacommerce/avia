defmodule Snitch.Core.Mixfile do
  use Mix.Project

  def project do
    [
      app: :snitch_core,
      version: "0.0.1",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: ">= 1.5.3",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      docs: docs()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Snitch.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support", "priv/repo/seed"]
  defp elixirc_paths(_), do: ["lib", "priv/repo/seed"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:postgrex, "~> 0.13.5"},
      {:ecto, "~> 2.2"},
      {:jason, "~> 1.0"},
      {:ex_money, "~> 2.5.0"},
      {:credo, "~> 0.9.1", only: :dev, runtime: false},
      {:credo_contrib, "~> 0.1.0-rc3", only: :dev, runtime: false},
      {:as_nested_set, git: "https://github.com/SagarKarwande/as_nested_set.git"},

      # auth
      {:comeonin, "~> 4.1.1"},
      {:argon2_elixir, "~> 1.2"},

      # countries etc
      {:ex_region, github: "oyeb/ex_region"},

      # docs and tests
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:excoveralls, "~> 0.8", only: :test},
      {:mox, "~> 0.3", only: :test},
      {:ex_machina, "~> 2.2", only: :test},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:inch_ex, "~> 0.5.6", only: [:docs, :dev]}
    ]
  end

  defp docs do
    [
      main: Snitch.Data.Schema.Order,
      source_url: "https://github.com/aviabird/snitch",
      groups_for_modules: groups_for_modules()
    ]
  end

  defp groups_for_modules do
    [
      Schema: ~r/^Snitch.Data.Schema.?/,
      Models: ~r/^Snitch.Data.Model.?/,
      Domain: ~r/^Snitch.Domain.?/
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
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seed/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
