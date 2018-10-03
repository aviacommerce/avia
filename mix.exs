defmodule Snitch.Mixfile do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      elixir: "~> 1.7.2",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.json": :test, "coveralls.html": :test],
      docs: docs()
    ]
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    [
      {:jason, "~> 1.0"},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:excoveralls, "~> 0.8", only: :test},
      {:inch_ex, "~> 0.5.6", only: [:docs, :dev]},
      {:distillery, "~> 2.0", runtime: false}
    ]
  end

  defp docs do
    [
      extras: ~w(README.md),
      main: "readme",
      source_url: "https://github.com/aviabird/snitch",
      groups_for_modules: groups_for_modules()
    ]
  end

  defp groups_for_modules do
    [
      Snitch: ~r/^Snitch.?/,
      SnitchApi: ~r/^SnitchApi.?/,
      SnitchAdmin: ~r/^AdminApp.?/
    ]
  end
end
