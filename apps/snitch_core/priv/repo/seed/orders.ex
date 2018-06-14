defmodule Snitch.Seed.Orders do
  @moduledoc false

  alias Ecto.DateTime
  alias Snitch.Data.Schema.{Address, LineItem, Order, User, Variant}
  alias Snitch.Repo

  require Logger

  @line_item %{
    variant_id: nil,
    order_id: nil,
    quantity: nil,
    unit_price: nil,
    total: nil,
    inserted_at: DateTime.utc(),
    updated_at: DateTime.utc()
  }

  @order %{
    number: nil,
    state: nil,
    billing_address_id: nil,
    shipping_address_id: nil,
    user_id: nil,
    adjustment_total: Money.new(0, :USD),
    promo_total: Money.new(0, :USD),
    item_total: Money.new(0, :USD),
    total: Money.new(0, :USD),
    inserted_at: DateTime.utc(),
    updated_at: DateTime.utc()
  }

  defp build_orders do
    variants = Repo.all(Variant)
    [address | _] = Repo.all(Address)
    [user | _] = Repo.all(User)

    digest = %{
      cart: [user_id: user.id],
      address: [user_id: user.id, address_id: address.id],
      payment: [user_id: user.id, address_id: address.id],
      processing: [user_id: user.id, address_id: address.id],
      shipping: [user_id: user.id, address_id: address.id],
      shipped: [user_id: user.id, address_id: address.id],
      cancelled: [user_id: user.id, address_id: address.id],
      completed: [user_id: user.id, address_id: address.id]
    }

    make_orders(digest, variants)
  end

  def seed_orders! do
    {orders, line_items} = build_orders()

    {count, order_structs} =
      Repo.insert_all(
        Order,
        orders,
        on_conflict: :nothing,
        conflict_target: [:number],
        returning: [:id, :number]
      )

    Logger.info("Inserted #{count} orders.")

    filtered_line_items =
      order_structs
      |> Enum.map(fn %{id: id, number: number} ->
        line_items
        |> Enum.reduce(&Map.merge/2)
        |> Map.fetch!(number)
        |> Stream.map(&Map.put(&1, :order_id, id))
        |> Enum.map(&Map.delete(&1, :number))
      end)
      |> List.flatten()

    {count, _} = Repo.insert_all(LineItem, filtered_line_items)
    Logger.info("Inserted #{count} line-items.")
  end

  def make_orders(digest, variants) do
    digest
    |> Enum.map(fn {state, opts} ->
      number = Nanoid.generate()

      line_items =
        variants
        |> Enum.shuffle()
        |> random_line_items()
        |> Stream.map(&Map.put(&1, :number, number))
        |> Enum.take(2 + :rand.uniform(3))

      item_total =
        line_items
        |> Stream.map(&Map.fetch!(&1, :total))
        |> Enum.reduce(&Money.add!/2)

      order = %{
        @order
        | number: number,
          state: "#{state}",
          user_id: opts[:user_id],
          billing_address_id: opts[:address_id],
          shipping_address_id: opts[:address_id],
          item_total: item_total,
          total: item_total
      }

      {order, %{number => line_items}}
    end)
    |> Enum.unzip()
  end

  def random_line_items(variants) do
    Stream.map(variants, fn v ->
      quantity = :rand.uniform(3)

      %{
        @line_item
        | variant_id: v.id,
          quantity: quantity,
          unit_price: v.selling_price,
          total: Money.mult!(v.selling_price, quantity)
      }
    end)
  end

  def seed_variants!(count) do
    Repo.insert_all(
      Variant,
      Enum.take(variants(), count),
      returning: [:id],
      on_conflict: :nothing
    )
  end

  def variants do
    0
    |> Stream.iterate(&(&1 + 1))
    |> Stream.map(&"shoes-nike-#{&1}")
    |> Stream.map(fn sku -> %{random_variant() | sku: sku} end)
  end

  def random_variant do
    price = random_price(9, 19)

    %{
      sku: nil,
      weight: Decimal.new("0.45"),
      height: Decimal.new("0.15"),
      depth: Decimal.new("0.1"),
      width: Decimal.new("0.4"),
      selling_price: price,
      cost_price: Money.sub!(price, Money.new("1.499", :USD)),
      inserted_at: DateTime.utc(),
      updated_at: DateTime.utc()
    }
  end

  defp random_price(min, delta) do
    Money.new(:USD, "#{:rand.uniform(delta) + min}.99")
  end
end
