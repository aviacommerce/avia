defmodule Snitch.Tools.Defaults do
  @moduledoc """
  Helper to fetch configured defaults for `Snitch`.
  """

  @callback config_app :: atom
  @callback fetch(atom) :: term
  @callback validate_config :: {:ok | :error, term}

  def config_app, do: Application.get_env(:snitch_core, :config_app)

  def fetch(key) do
    with {:ok, core_config_app} <- Application.fetch_env(:snitch_core, :config_app),
         {:ok, defaults} <- Application.fetch_env(core_config_app, :defaults) do
      case Keyword.fetch(defaults, key) do
        {:ok, _} = value -> value
        :error -> {:error, "default '#{key}' not set"}
      end
    else
      :error ->
        {:error, "Could not fetch any 'defaults' from config under ':core_config_app'"}
    end
  end

  def validate_config, do: :ok
end
