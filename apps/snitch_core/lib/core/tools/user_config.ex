defmodule Snitch.Tools.UserConfig do
  @moduledoc """
  Helper to fetch user configurations.
  """

  @callback fetch(atom) :: {:ok, term} | :error
  @callback get(atom) :: term

  @doc """
  Fetches data from `config` defined by users in their application.

  The function takes the `key` as input to fetch data for and returns 
  the `value` corresponding to that key.
  Sample configuration.
  ```
  config :snitch_core,
    calculators: [`SomeCustomCalculator`, `AnotherCalculator`]
  ```
  """
  @spec fetch(atom) :: {:ok, term} | :error
  def fetch(key) do
    Application.fetch_env(:snitch_core, key)
  end

  @doc """
  Gets data from `config` defined by users in their application.

  The function takes the `key` as input to fetch data for and returns 
  the `value` corresponding to that key.
  Sample configuration.
  ```
  config :snitch_core,
    calculators: [`SomeCustomCalculator`, `AnotherCalculator`]
  ```
  """
  @spec get(atom) :: term
  def get(key) do
    Application.get_env(:snitch_core, key)
  end
end
