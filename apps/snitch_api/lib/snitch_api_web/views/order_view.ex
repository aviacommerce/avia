defmodule SnitchApiWeb.OrderView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  location("/orders/:id")

  attributes([
    :state,
    :user_id,
    :billing_address,
    :shipping_address,
    :number,
    :state,
    :total,
    :promot_total,
    :adjustment_total,
    :item_total
  ])

  has_many(
    :line_items,
    serializer: SnitchApiWeb.LineItemView,
    include: true
  )

  def line_items(struct, _conn) do
    struct
    |> Snitch.Repo.preload(:line_items)
    |> Map.get(:line_items)
  end
end
