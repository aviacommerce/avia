defmodule Snitch.Data.Model.PackageItem do
  @moduledoc """
  PackageItem API.
  """

  use Snitch.Data.Model
  alias Snitch.Data.Schema.PackageItem

  # TODO: the CUD operations should update the parent package!

  @doc """
  Creates a new `PackageItem`.
  """
  @spec create(map) :: {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def create(params) do
    QH.create(PackageItem, params, Repo)
  end

  @doc """
  Updates the `package_item` with `params`.
  """
  @spec update(map, PackageItem.t()) :: {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def update(params, %PackageItem{} = package_item) do
    QH.update(PackageItem, params, package_item, Repo)
  end

  @doc """
  Deletes the `package_item`.
  """
  @spec delete(PackageItem.t()) ::
          {:ok, PackageItem.t()} | {:error, Ecto.Changeset.t()} | {:error, :not_found}
  def delete(%PackageItem{} = package_item) do
    QH.delete(PackageItem, package_item, Repo)
  end

  @spec get(non_neg_integer | map) :: {:ok, PackageItem.t()} | {:error, atom}
  def get(query_fields) do
    QH.get(PackageItem, query_fields, Repo)
  end

  @spec get_all :: list(PackageItem.t())
  def get_all, do: Repo.all(PackageItem)
end
