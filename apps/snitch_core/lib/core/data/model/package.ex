defmodule Snitch.Data.Model.Package do
  @moduledoc """
  Package API.
  """

  use Snitch.Data.Model
  alias Snitch.Data.Schema.Package
  alias Snitch.Tools.Money

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

  @doc """

  Calculate the cost of packages for an order

  """

  @spec compute_package_total(Order.t()) :: Money.t()
  def compute_package_total(order) do
    case get_packages(order) do
      [] ->
        Money.zero!()

      packages ->
        packages
        |> Stream.map(&Map.fetch!(&1, :total))
        |> Enum.reduce(&Money.add!/2)
        |> Money.reduce()
    end
  end

  @doc """

  Query of packages related to order

  """

  # @spec get_packages(Order.t()) ::
  def get_packages(order) do
    query =
      from(
        p in Package,
        where: p.order_id == ^order.id
      )

    Repo.all(query)
  end
end
