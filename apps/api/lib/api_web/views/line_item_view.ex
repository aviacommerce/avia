defmodule ApiWeb.LineItemView do
  use ApiWeb, :view
  import ApiWeb.ProductView, only: [image_variant: 1]

  def render("line_item.json", %{line_item: line_item}) do
    line_item
    |> Map.from_struct()
    |> Map.drop(~w[__meta__ order variant]a)
    |> Map.merge(%{
      "adjustments" => [],
      "single_display_amount" => Money.to_string!(line_item.unit_price),
      "display_amount" => Money.to_string!(line_item.total),
      "total" => line_item.total.amount,
      "price" => line_item.unit_price.amount,
      "variant" => render_variant(line_item.variant)
    })
  end

  defp render_variant(variant) do
    variant
    |> Map.from_struct()
    |> Map.drop(~w[__meta__ stock_items shipping_category images product]a)
    |> Map.merge(%{
      "name" => variant.sku,
      "price" => variant.selling_price.amount,
      "is_master" => true,
      "slug" => variant.sku,
      "cost_price" => variant.cost_price.amount,
      "option_values" => [],
      "display_price" => Money.to_string!(variant.selling_price),
      "options_text" => "",
      "in_stock" => true,
      "is_backorderable" => true,
      "is_orderable" => true,
      "total_on_hand" => 100,
      "is_destroyed" => false,
      "images" => Enum.map(variant.images, &image_variant/1)
    })
  end
end
