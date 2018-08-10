defmodule Snitch.Data.Schema.Variation do
  @moduledoc false

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.Product

  schema "snitch_product_variants" do
    belongs_to(:parent_product, Product)
    # This can be uniquely indexed
    belongs_to(:child_product, Product)
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [])
    |> cast_assoc(:child_product, required: true, with: &Product.child_product/2)
  end
end
