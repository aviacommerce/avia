defmodule Snitch.Demo.Order do

  import Snitch.Tools.Helper.Order, only: [line_items_with_price: 2]

  alias Ecto.DateTime
  alias Snitch.Data.Schema.{LineItem, Order, ShippingCategory, User, Product, Taxon}
  alias Snitch.Core.Tools.MultiTenancy.Repo

  require Logger

  @order %{
    number: nil,
    state: nil,
    user_id: nil,
    billing_address: nil,
    shipping_address: nil,
    inserted_at: DateTime.utc(),
    updated_at: DateTime.utc()
  }

  defp build_orders(start_time) do
    variants = Repo.all(Product)
    [user | _] = Repo.all(User)

    digest = [
      %{quantity: [5, 5, 1, 0, 0, 0, 0], user_id: user.id, state: :cart},
      %{quantity: [0, 0, 0, 0, 0, 100], user_id: user.id, state: :cart},
      %{quantity: [5, 0, 8, 12, 0, 0, 0], user_id: user.id, state: :cart}
    ]

    make_orders(digest, variants, start_time)

  end

  def seeds do
    Repo.delete_all(Order)
    end_time = Ecto.DateTime.utc()
    start_time = %{end_time | day: end_time.day - 25}
    seed_orders(start_time)
  end

  def seed_orders(start_time) do
    end_time = Ecto.DateTime.utc()

    case  DateTime.compare(start_time, end_time) do
      :lt  ->
        seed_orders!(start_time)
        # start_time = %{start_time | day: start_time.day + 1}
        # seed_orders(start_time)
      _ ->
        nil
    end
  end

  def seed_orders!(start_time) do

    {orders, line_items} = build_orders(start_time)
    {count, order_structs} =
      Repo.insert_all(
        Order,
        orders,
        on_conflict: :nothing,
        conflict_target: [:number],
        returning: true
      )
    Logger.info("Inserted #{count} orders.")

    line_items =
      order_structs
      |> Stream.zip(line_items)
      |> Enum.map(fn {%{id: id}, items} ->
        Enum.map(items, &Map.put(&1, :order_id, id))
      end)
      |> List.flatten()

    {count, _} = Repo.insert_all(LineItem, line_items)
    Logger.info("Inserted #{count} line-items.")
    start_time = %{start_time | day: start_time.day + 1}
    seed_orders(start_time)
  end

  def make_orders(digest, variants, start_time) do
    digest
    |> Stream.with_index()
    |> Enum.map(fn {manifest, index} ->
      number = "#{Nanoid.generate()}-#{index}"
      line_items = line_items_with_price(variants, manifest.quantity)

      line_items = Enum.map(line_items, fn(line_item) ->
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
