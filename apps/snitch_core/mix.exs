defmodule Snitch.Core.Mixfile do
  use Mix.Project

  @version "0.0.1"

  def project do
    [
      app: :snitch_core,
      version: @version,
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.13.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      package: package(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      docs: docs(),
      preferred_cli_env: [
        "test.multi": :test
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Snitch.Application, []},
      extra_applications: [:logger, :runtime_tools, :sentry, :cachex]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support", "priv/repo/seed"]
  defp elixirc_paths(_), do: ["lib", "priv/repo/seed", "priv/repo/demo", "priv/tasks"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:postgrex, "~> 0.16.3"},
      {:ecto, "~> 3.8.4"},
      {:bamboo, "~> 1.1"},
      {:combination, "~> 0.0.3"},
      {:bamboo_smtp, "~> 1.6.0"},
      {:bamboo_eex, "~> 0.1.0"},
      {:ex_money, "~> 5.12"},
      {:ex_money_sql, "~> 1.7"},
      {:rummage_ecto, "~> 2.0"},
      {:credo, "~> 0.9.1", only: :dev, runtime: false},
      {:credo_contrib, "~> 0.1.0-rc3", only: :dev, runtime: false},
      {:as_nested_set, "~> 3.4"},
      # {:ecto_atom, "~> 1.0.0", override: true},
      {:ecto_identifier, "~> 0.2.0"},
      {:ecto_autoslug_field, "~> 3.0"},

      # state machine
      {:beepbop, github: "aviacommerce/beepbop", branch: "develop"},

      # time
      {:timex, "~> 3.1"},

      # auth
      {:comeonin, "~> 4.1.1"},
      {:argon2_elixir, "~> 1.2"},

      # countries etc
      {:ex_region, github: "oyeb/ex_region", branch: "embed-json"},

      # docs and tests
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:excoveralls, "~> 0.8.2", only: :test},
      {:mox, "~> 0.3", only: :test},
      {:mock, "~> 0.3.0", only: :test},
      {:ex_machina, "~> 2.7", only: :test},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:inch_ex, "~> 0.5.6", only: [:docs, :dev]},

      # csp
      {:aruspex, github: "oyeb/aruspex", branch: "tweaks"},

      # payments
      {:snitch_payments, github: "aviacommerce/avia_payments", branch: "develop"},

      # image uploading
      {:arc, "~> 0.11.0"},
      {:arc_ecto, "~> 0.11.3"},
      {:ex_aws, "~> 2.1"},
      {:ex_aws_s3, "~> 2.0"},
      {:hackney, "~> 1.9"},
      {:sweet_xml, "~> 0.6"},
      {:plug_cowboy, "~> 2.5"},
      {:plug, "~> 1.0"},

      # unique id generator
      {:nanoid, "~> 2.0"},
      {:sentry, "~> 7.0"},
      {:jason, "~> 1.1"},
      {:nimble_csv, "~> 1.2.0"},

      # Multi tenancy
      {:triplex, "~> 1.3.0"},

      # xml
      {:xml_builder, "~> 2.1", override: true},

      # ecto_enum
      {:ecto_enum, "~> 1.4.0"},

      # Elastic search integration
      {:elasticsearch, "~> 0.6.0"},

      # Caching
      {:cachex, "~> 3.1"}
    ]
  end

  defp package do
    [
      contributors: [],
      maintainers: [],
      licenses: [],
      links: %{
        "GitHub" => "https://github.com/aviabird/snitch",
        "Readme" => "https://github.com/aviabird/snitch/blob/v#{@version}/README.md"
        # "Changelog" => "https://github.com/aviabird/snitch/blob/v#{@version}/CHANGELOG.md"
      }
    ]
  end

  defp docs do
    [
      extras: ~w(README.md),
      main: "readme",
      source_ref: "v#{@version}",
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
      "ecto.load.demo": "run priv/repo/demo/demo.exs",
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seed/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "ecto.rebuild": ["ecto.drop", "ecto.create --quiet", "ecto.migrate"],
      "ecto.load.demo": ["run priv/repo/demo/demo.exs"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
      "test.multi": [
        "ecto.drop --quiet",
        "ecto.create --quiet",
        "ecto.migrate",
        "run test/support/multitenancy_setup.exs amazon",
        "test"
      ],
      "seed.multi": [
        "run test/support/multitenancy_setup.exs amazon",
        "run priv/repo/seed/seeds.exs"
      ]
    ]
  end
end
