defmodule Snitch.Tools.Defaults do
  @moduledoc """
  Helper to fetch configured defaults for `Snitch`.
  """

  @callback fetch(atom) :: term
  @callback validate_config :: {:ok | :error, term}

  def fetch(key) do
    with {:ok, defaults} <- Application.fetch_env(:snitch_core, :defaults) do
      case Keyword.fetch(defaults, key) do
        {:ok, _} = value -> value
        :error -> {:error, "default '#{key}' not set"}
      end
    else
      :error ->
        {:error, "Could not fetch any 'defaults'"}
    end
  end

  def validate_config, do: :ok
end
