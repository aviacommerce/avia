defmodule Snitch.Demo.Order do
  use Timex

  import Snitch.Tools.Helper.Order, only: [line_items_with_price: 2]

  alias Ecto.DateTime

  alias Snitch.Data.Schema.{
    LineItem,
    Order,
    OrderAddress,
    Package,
    PackageItem,
    Product,
    ShippingCategory,
    StockLocation,
    Taxon,
    User
  }

  alias Snitch.Data.Model.GeneralConfiguration, as: GCModel
  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias Snitch.Data.Model.{Country, State}

  require Logger

  @package_states ["processing", "ready", "shipped", "delivered", "complete"]

  @order %{
    number: nil,
    state: nil,
    user_id: nil,
    billing_address: nil,
    shipping_address: nil,
    inserted_at: Timex.now(),
    updated_at: Timex.now()
  }

  defp build_orders(start_time) do
    variants = Product |> Repo.all() |> Enum.take_random(5)
    user = Repo.all(User) |> Enum.random()

    address = %OrderAddress{
      first_name: user.first_name,
      last_name: user.last_name,
      address_line_1: "10-8-80 Malibu Point",
      zip_code: "90265",
      city: "Malibu",
      phone: "1234567890",
      state_id: State.get(%{code: "US-CA"}).id,
      country_id: Country.get(%{iso: "US"}).id
    }

    digest = [
      %{
        quantity: Enum.map(1..5, fn _ -> Enum.random(1..3) end),
        user_id: user.id,
        state: :confirmed,
        address: address
      }
    ]

    digest_list = digest |> List.duplicate(Enum.random(1..5)) |> List.flatten()
    make_orders(digest_list, variants, start_time)
  end

  def create_orders do
    Repo.delete_all(Package)
    Repo.delete_all(Order)
    end_time = Timex.now()
    start_time = Timex.shift(end_time, months: -1)
    seed_orders(start_time)
  end

  def seed_orders(start_time) do
    end_time = Timex.now()

    case Timex.before?(start_time, end_time) do
      true ->
        seed_orders!(start_time)

      false ->
        nil
    end
  end

  def seed_orders!(start_time) do
    currency = GCModel.fetch_currency()

    {orders, line_items} = build_orders(start_time)
    {count, order_structs} = create_orders(orders)
    Logger.info("Inserted #{count} orders.")

    packages = build_packages(order_structs, start_time, currency)
    {count, package_structs} = create_packages(packages)
    Logger.info("Created #{count} packages.")

    line_items = build_line_items_for_orders(order_structs, line_items)
    {count, line_item_structs} = Repo.insert_all(LineItem, line_items, returning: true)
    Logger.info("Inserted #{count} line-items.")

    package_items = build_package_items(line_item_structs, start_time, currency)
    {count, package_item_structs} = create_package_items(package_items)
    Logger.info("Created #{count} package_items.")

    start_time = Timex.shift(start_time, days: 1)
    seed_orders(start_time)
  end

  defp create_orders(orders) do
    Repo.insert_all(
      Order,
      orders,
      on_conflict: :nothing,
      conflict_target: [:number],
      returning: true
    )
  end

  defp build_packages(order_structs, start_time, currency) do
    order_structs
    |> Enum.map(fn order ->
      %{
        number: Nanoid.generate(),
        order_id: order.id,
        state: Enum.random(@package_states),
        cost: Money.new(currency, 160),
        shipping_tax: Money.new(currency, 0),
        origin_id: Enum.random(Repo.all(StockLocation)).id,
        shipping_category_id: Enum.random(Repo.all(ShippingCategory)).id,
        inserted_at: start_time,
        updated_at: start_time
      }
    end)
  end

  defp create_packages(packages) do
    Repo.insert_all(
      Package,
      packages,
      on_conflict: :nothing,
      conflict_target: [:number],
      returning: true
    )
  end

  defp build_line_items_for_orders(order_structs, line_items) do
    order_structs
    |> Stream.zip(line_items)
    |> Enum.map(fn {%{id: id}, items} ->
      Enum.map(items, &Map.put(&1, :order_id, id))
    end)
    |> List.flatten()
  end

  defp build_package_items(line_item_structs, start_time, currency) do
    line_item_structs
    |> Repo.preload(order: :packages)
    |> Enum.map(fn item ->
      package = item.order.packages |> List.first()

      %{
        number: Nanoid.generate(),
        quantity: item.quantity,
        package_id: package.id,
        state: "pending",
        shipping_tax: Money.new(currency, 0),
        tax: Money.new(currency, 0),
        backordered?: true,
        product_id: item.product_id,
        line_item_id: item.id,
        inserted_at: start_time,
        updated_at: start_time
      }
    end)
  end

  defp create_package_items(package_items) do
    Repo.insert_all(
      PackageItem,
      package_items,
      on_conflict: :nothing,
      conflict_target: [:number],
      returning: true
    )
  end

  def make_orders(digest, variants, start_time) do
    digest
    |> Stream.with_index()
    |> Enum.map(fn {manifest, index} ->
      number = "#{Nanoid.generate()}-#{index}"
      line_items = line_items_with_price(variants, manifest.quantity)

      line_items =
        Enum.map(line_items, fn line_item ->
          line_item
          |> Map.put(:inserted_at, start_time)
          |> Map.put(:updated_at, start_time)
        end)

      order = %{
        @order
        | number: number,
          state: "#{manifest.state}",
          user_id: manifest[:user_id],
          billing_address: manifest[:address],
          shipping_address: manifest[:address],
          inserted_at: start_time,
          updated_at: start_time
      }

      {order, line_items}
    end)
    |> Enum.unzip()
  end
end
