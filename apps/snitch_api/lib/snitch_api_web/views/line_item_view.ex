defmodule SnitchApiWeb.LineItemView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView
  alias Snitch.Repo

  location("/line_items/:id")

  attributes([:quantity, :unit_price])

  has_one(
    :order,
    serializer: SnitchApiWeb.OrderView,
    include: true
  )

  # This needs variant_view which is alreday updated in products api
  # todo: uncomment after merging products api 

  # has_one(
  #   :variant,
  #   serializer: SnitchApiWeb.VariantView,
  #   include: true
  # )
  # def variant(struct, _conn) do
  #   struct
  #   |> Repo.preload(:variant)
  #   |> Map.get(:variant)
  # end
  #
  def order(struct, _conn) do
    struct
    |> Repo.preload(:order)
    |> Map.get(:order)
  end
end
