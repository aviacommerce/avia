defmodule ApiWeb.PackageView do
  use ApiWeb, :view

  def render("package.json", %{package: package}) do
    manifest =
      Enum.map(package.items, fn item ->
        item
        |> Map.take(~w[variant_id state]a)
        |> Map.put(:quantity, item.quantity + item.delta)
      end)

    items =
      Enum.map(package.items, fn item ->
        item
        |> Map.from_struct()
        |> Map.drop(~w[__meta__ line_item order package variant]a)
      end)

    shipping_methods = render_many(package.shipping_methods, __MODULE__, "shipping_method.json")

    [x | xs] =
      package.shipping_methods
      |> Enum.sort_by(fn %{cost: %{amount: amount}} -> amount end)
      |> render_many(__MODULE__, "shipping_rate.json")
      |> Stream.with_index()
      |> Enum.map(fn {sr, index} -> Map.put(sr, :id, index) end)

    shipping_rates = [%{x | selected: true} | xs]

    Map.merge(
      %{
        items: items,
        manifest: manifest,
        adjustments: [],
        stock_location_name: package.origin.name,
        shipping_methods: shipping_methods,
        shipping_rates: shipping_rates,
        selected_shipping_rate: %{x | selected: true}
      },
      Map.take(package, ~w[number order_id tracking state]a)
    )
  end

  def render("shipping_method.json", %{package: sm}) do
    sm
    |> Map.from_struct()
    |> Map.drop([:__meta__, :cost])
    |> Map.merge(%{
      zones: [],
      shipping_categories: []
    })
  end

  def render("shipping_rate.json", %{package: sm}) do
    sm
    |> Map.from_struct()
    |> Map.drop([:__meta__])
    |> Map.merge(%{
      cost: sm.cost.amount,
      shipping_method_id: sm.id,
      shipping_method_code: nil,
      display_cost: Money.to_string!(Money.new(sm.cost.amount, sm.cost.currency)),
      selected: false
    })
  end
end
