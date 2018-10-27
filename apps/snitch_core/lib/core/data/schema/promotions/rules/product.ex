defmodule Snitch.Data.Schema.PromotionRule.Product do
  @moduledoc false

  use Snitch.Data.Schema

  alias Snitch.Domain.Order, as: OrderDomain

  embedded_schema do
    field(:product_list, {:array, :float})
  end

  def changeset(%__MODULE__{} = data, params) do
    data
    |> cast(params, [:product])
  end

  def eligible(order, rule_data) do
    ## TODO check if a product is found in order present in the list
    {false, "order not eligible"}
  end
end
