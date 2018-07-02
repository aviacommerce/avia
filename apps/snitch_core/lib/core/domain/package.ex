defmodule Snitch.Domain.Package do
  @moduledoc """
  Package helpers.
  """

  alias Snitch.Data.Model.Package
  alias Snitch.Tools.Money, as: MoneyTools

  def set_shipping_method(package, shipping_method_id) do
    # TODO: clean up this hack!
    #
    # if we can't find the selected shipping method, we must force the
    # Packge.update to fail
    # Eventually replace with some nice API contract/validator.
    zero = MoneyTools.zero!()

    shipping_method =
      Enum.find(package.shipping_methods, %{cost: zero, id: nil}, fn %{id: id} ->
        id == shipping_method_id
      end)

    package_total =
      Enum.reduce(
        [shipping_method.cost],
        &Money.add!/2
      )

    Package.update(package, %{
      cost: shipping_method.cost,
      total: package_total,
      tax_total: zero,
      promo_total: zero,
      adjustment_total: zero,
      shipping_method_id: shipping_method.id
    })
  end
end
