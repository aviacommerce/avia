defmodule Snitch.Domain.Shipment do
  # TODO: migrate to the Package schema.
  @moduledoc """
  The coordinator, packer, estimator and prioritizer -- all in one.

  The package struct:
  ```
  %{
    hash: TBD
    items: [
      %{
        variant: %Product{},
        line_item: %LineItem{},
        product_id: 0,
        state: :fulfilled | :backorder,
        quantity: 0,
        delta: line_item.quantity - package_quantity
       }
    ],
    zone: %Zone{}
    shipping_methods: [%ShippingMethod{}],
    shipping_costs: [%Money{}],
    origin: %StockLocation{}, # the `:stock_items` will not be "loaded"
    category: %ShippingCategory{},
    backorders?: true | false,
    variants: %MapSet{} # set of product_ids
   }
  ```
  """

  use Snitch.Domain

  alias Snitch.Data.Model.StockLocation
  alias Snitch.Data.Schema.{Order}
  alias Snitch.Domain.{PackageItem, ShippingMethod, Zone}

  @doc """
  Returns a list of potentially shippable packages.

  The function fetches all the stock information (from all stock locations) that
  is relevant to this order and attempts to fulfill the order separately from
  each stock location.

  The final result is a "flattened" list of maps, each representing a
  `Package.t` struct.

  ## Note
  Some `Package.t` fields are not computed, like: `package.tax`.

  Similarily, some fields of the constituent `PackageItem` are not computed as
  well, like: `package_item.tax`, `package_item.shipping_tax`.
  """
  @spec default_packages(Order.t()) :: [map]
  def default_packages(%Order{} = order) do
    order = Repo.preload(order, line_items: [])
    variant_ids = Enum.map(order.line_items, fn %{product_id: id} -> id end)
    stock_locations = StockLocation.get_all_with_items_for_variants(variant_ids)

    line_items =
      Enum.reduce(order.line_items, %{}, fn %{product_id: v_id} = li, acc ->
        Map.put(acc, v_id, li)
      end)

    stock_locations
    |> Stream.map(&package(&1, line_items))
    |> Stream.reject(fn x -> is_nil(x) end)
    |> Stream.map(&attach_zones(&1, order.shipping_address))
    |> Enum.map(&split_by_category/1)
    |> List.flatten()
    |> Stream.map(&attach_shipping_methods(&1, order))
    |> Enum.reject(fn x -> is_nil(x) end)
  end

  defp package(stock_location, line_items) do
    items =
      stock_location.stock_items
      |> Stream.map(&make_item(&1, line_items))
      |> Stream.reject(fn x -> is_nil(x) end)
      |> Enum.map(&attach_item_tax(&1, stock_location))

    if items == [],
      do: nil,
      else: %{
        items: items,
        shipping_methods: nil,
        origin: struct(stock_location, stock_items: nil),
        category: nil,
        backorders?: nil
      }
  end

  defp make_item(%{product: v} = stock_item, line_items) do
    li = line_items[v.id]
    state = item_state(stock_item, li)
    package_quantity = min(li.quantity, stock_item.count_on_hand)

    if is_nil(state),
      do: nil,
      else: %{
        state: state,
        quantity: package_quantity,
        delta: li.quantity - package_quantity,
        line_item: li,
        variant: v
      }
  end

  defp item_state(stock_item, line_item) do
    if stock_item.count_on_hand >= line_item.quantity do
      :fulfilled
    else
      if stock_item.backorderable, do: :backordered, else: nil
    end
  end

  defp attach_item_tax(item, stock_location) do
    tax = PackageItem.tax(item, stock_location)
    Map.put(item, :tax, tax)
  end

  defp attach_zones(package, shipping_address) do
    Map.put(package, :zones, Zone.common(package.origin, shipping_address))
  end

  defp attach_shipping_methods(package, order) do
    {sz, cz} = package.zones
    zones = sz ++ cz

    case ShippingMethod.for_package(zones, package.category) do
      [] ->
        nil

      methods ->
        costs = Enum.map(methods, &ShippingMethod.cost(&1, order))

        package
        |> Map.put(:shipping_methods, methods)
        |> Map.put(:shipping_costs, costs)
    end
  end

  defp split_by_category(package) do
    package.items
    |> Enum.group_by(fn %{variant: v} -> v.shipping_category_id end)
    |> Enum.reduce([], fn {_sc_id, [item | _] = items}, acc ->
      [
        %{
          items: items,
          category: item.variant.shipping_category,
          origin: package.origin,
          shipping_methods: package.shipping_methods,
          zones: package.zones,
          backorders?: Enum.any?(items, fn %{state: state} -> state == :backordered end),
          variants:
            items
            |> Enum.map(fn %{variant: v} -> v.id end)
            |> MapSet.new()
        }
        | acc
      ]
    end)
  end

  def to_package(package, order) do
    shipping_methods =
      package.shipping_methods
      |> Stream.zip(package.shipping_costs)
      |> Enum.map(fn {method, cost} ->
        Map.put(method, :cost, cost)
      end)

    items =
      Enum.map(package.items, fn %{line_item: li, variant: v} = item ->
        %{
          original_amount: unit_price,
          tax: tax
        } = PackageItem.unit_price_with_tax(li, order, package.origin)

        item
        |> Map.put(:unit_price, unit_price)
        |> Map.put(:tax, tax)
        |> Map.put(:line_item_id, li.id)
        |> Map.put(:product_id, v.id)
        |> Map.put(:backordered?, item.delta > 0)
        |> Map.put(:state, Atom.to_string(item.state))
      end)

    %{
      order_id: order.id,
      origin_id: package.origin.id,
      shipping_category_id: package.category.id,
      shipping_methods: shipping_methods,
      items: items,
      state: if(package.backorders?, do: "backordered", else: "pending")
    }
  end

  ###############################################################################
  #                             REFLECTION FUNCTIONS                            #
  ###############################################################################

  def has_variants?(package, target_ids) do
    MapSet.subset?(MapSet.new(target_ids), package.variants)
  end

  def from(packages, origin) do
    Enum.filter(packages, fn %{origin: %{id: id}} -> id == origin.id end)
  end
end
