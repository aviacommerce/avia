defmodule Snitch.Data.Model.StoreProps do
  @moduledoc """
  Use this model to store any key value pair struct that will be needed for
  application and needs to be persisted.

  For eg: We might want to store some secret key or API keys for application we
  can store them using this Model.
  """

  use Snitch.Data.Model

  alias Snitch.Data.Schema.StoreProps

  @doc """
  Saves the key value pair irrespective the key is present or not.
  """
  @spec store(String.t(), String.t()) :: {:ok, StoreProps.t()} | {:error, Ecto.Changeset.t()}
  def store(key, val) do
    case get(key) do
      {:ok, prop} -> update_prop(prop, val)
      {:error, :not_found} -> create_prop(key, val)
    end
  end

  defp create_prop(key, val) do
    changeset = StoreProps.changeset(%StoreProps{}, %{key: key, value: val})
    Repo.insert(changeset)
  end

  defp update_prop(store_prop, val) do
    changeset = StoreProps.changeset(store_prop, %{value: val})
    Repo.update(changeset)
  end

  @doc """
  Get the Store props by key
  """
  @spec get(String.t()) :: {:ok, StoreProps.t()} | {:error, :not_found}
  def get(key) do
    case Repo.get_by(StoreProps, key: key) do
      %StoreProps{} = prop -> {:ok, prop}
      _ -> {:error, :not_found}
    end
  end
end
