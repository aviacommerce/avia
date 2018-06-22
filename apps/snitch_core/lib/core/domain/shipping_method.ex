defmodule Snitch.Domain.ShippingMethod do
  @moduledoc """
  ShippingMethod helpers.
  """

  use Snitch.Domain

  alias Snitch.Data.Model.ShippingMethod
  alias Snitch.Data.Schema.ShippingMethod, as: SMSchema
  alias Snitch.Data.Schema.{Order, ShippingCategory}

  @doc """
  Returns the `ShippingMethod.t` structs that are applicable for the given
  package.

  The selection takes into consideration both the (shipping) `category` as well
  as the `zones` which it qualifies for.

  For more info on how zones are calculated, refer
  `Snitch.Domain.Zone.common/2`.
  """
  @spec for_package([Zone.t()], ShippingCategory.t()) :: [SMSchema.t()]
  def for_package([], _), do: []

  def for_package(zones, %ShippingCategory{} = category)
      when is_list(zones) do
    Repo.all(ShippingMethod.for_package_query(zones, category))
  end

  @doc """
  Returns the shipping cost
  """
  @spec cost(ShippingMethod.t(), Order.t()) :: Money.t()
  def cost(%SMSchema{} = _shipping_method, %Order{} = _order) do
    Money.new(0, :USD)
  end
end
