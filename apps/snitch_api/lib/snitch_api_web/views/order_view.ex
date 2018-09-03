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
    :order_total_amount,
    :promot_total,
    :adjustment_total,
    :item_count
  ])

  has_many(
    :line_items,
    serializer: SnitchApiWeb.LineItemView,
    include: true
  )

  has_many(
    :payments,
    serializer: SnitchApiWeb.PaymentView,
    include: false
  )

  def item_count(order, _) do
    order.line_items
    |> Enum.reduce(0, fn line_item, acc ->
      acc = acc + line_item.quantity
    end)
  end

  def order_total_amount(order, _) do
    order.line_items
    |> Enum.reduce(Money.new(:USD, 0), fn line_item, acc ->
      {:ok, total} = Money.mult(line_item.unit_price, line_item.quantity)
      {:ok, acc} = Money.add(acc, total)
      acc
    end)
  end

  def line_items(struct, _conn) do
    struct
    |> Snitch.Repo.preload(:line_items)
    |> Map.get(:line_items)
  end

  def shipping_address(struct, _conn) do
    struct
    |> Map.get(:shipping_address)
    |> case do
      nil ->
        nil

      address ->
        address
        |> Map.from_struct()
        |> Map.delete(:__meta__)
    end
  end

  def billing_address(struct, _conn) do
    struct
    |> Map.get(:billing_address)
    |> case do
      nil ->
        nil

      address ->
        address
        |> Map.from_struct()
        |> Map.delete(:__meta__)
    end
  end

  def render("empty.json-api", %{data: %{}}) do
    %{data: nil}
  end
end
