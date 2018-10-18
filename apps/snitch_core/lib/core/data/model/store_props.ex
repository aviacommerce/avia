defmodule Snitch.Data.Model.StoreProps do
  @moduledoc false

  use Snitch.Data.Model

  alias Snitch.Data.Schema.StoreProps

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

  def get(key) do
    case Repo.get_by(StoreProps, key: key) do
      %StoreProps{} = prop -> {:ok, prop}
      _ -> {:error, :not_found}
    end
  end
end
