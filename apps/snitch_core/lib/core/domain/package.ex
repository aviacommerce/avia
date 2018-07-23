defmodule Snitch.Domain.Package do
  @moduledoc """
  Package helpers.
  """

  use Snitch.Domain

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
end
