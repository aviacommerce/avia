defmodule Snitch.Data.Model.Package do
  @moduledoc """
  Package API.
  """

  use Snitch.Data.Model
  alias Snitch.Data.Schema.Package

  @doc """
  Creates a package with supplied `params` and package `items`.

  A list of `PackageItem` params can be provided as the second argument.
  * These `PackageItem` params will be created (casted, to be precise) along
    with this `Package`.

  ## See also
  `Ecto.Changeset.cast_assoc/3`
  """
  @spec create(map, [map] | nil) :: {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def create(params) do
    QH.create(Package, params, Repo)
  end

  def create(params, items) do
    QH.create(Package, Map.put(params, :items, items), Repo)
  end

  @doc """
  Updates the `package` with supplied `params`.

  To add, update, or remove individual `PackageItem`s, please use
  `Snitch.Data.Model.PackageItem`.
  """
  @spec update(Package.t(), map) :: {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def update(package, params) do
    QH.update(Package, params, package, Repo)
  end

  @spec get(non_neg_integer | map) :: Package.t()
  def get(query_fields) do
    QH.get(Package, query_fields, Repo)
  end
end
