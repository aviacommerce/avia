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
  @spec create(map) :: {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def create(params) do
    QH.create(Package, params, Repo)
  end

  @doc """
  Updates the `package` with supplied `params`.

  To update the `:items` of the `package`, use `Snitch.Data.Model.PackageItem`.
  """
  @spec update(Package.t(), map) :: {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def update(package, params) do
    QH.update(Package, params, package, Repo)
  end

  @spec get(non_neg_integer | map) :: {:ok, Package.t()} | {:error, atom}
  def get(query_fields) do
    QH.get(Package, query_fields, Repo)
  end

  @doc """
  Deletes the `package`.
  """
  @spec delete(Package.t()) :: {:ok, Package.t()} | {:error, Ecto.Changeset.t()}
  def delete(%Package{} = package) do
    QH.delete(Package, package, Repo)
  end
end
