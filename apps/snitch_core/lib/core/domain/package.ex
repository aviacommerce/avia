defmodule Snitch.Domain.Package do
  @moduledoc """
  Package helpers.
  """

  use Snitch.Domain

  import Ecto.Query
  alias Ecto.Multi
  alias Snitch.Core.Tools.MultiTenancy.MultiQuery
  alias Snitch.Data.Schema.Package
  alias Snitch.Tools.Money, as: MoneyTools

  @doc """
  Saves
  """
  @spec set_shipping_method(Package.t(), non_neg_integer) :: Package.t()
  def set_shipping_method(package, shipping_method_id) do
    # TODO: clean up this hack!
    #
    # if we can't find the selected shipping method, we must force the
    # Packge.update to fail
    # Eventually replace with some nice API contract/validator.
    shipping_method =
      Enum.find(package.shipping_methods, %{cost: Money.zero(:INR), id: nil}, fn %{id: id} ->
        id == shipping_method_id
      end)

    params = %{
      cost: shipping_method.cost,
      shipping_tax: shipping_tax(package),
      shipping_method_id: shipping_method.id
    }

    package
    |> Package.shipping_changeset(params)
    |> Repo.update()
  end

  @spec shipping_tax(Package.t()) :: Money.t()
  def shipping_tax(_package) do
    MoneyTools.zero!()
  end

  @doc """
  Returns an `Ecto.Multi()` struct to perform an update on `packages` for the
  supplied `order`.
  """
  @spec update_all_for_order(Multi.t(), Order.t(), map) :: Multi.t()
  def update_all_for_order(multi, order, params) do
    query =
      from(
        package in Package,
        where: package.order_id == ^order.id
      )

    MultiQuery.update_all(multi, :update_package_params, query, set: params)
  end
end
