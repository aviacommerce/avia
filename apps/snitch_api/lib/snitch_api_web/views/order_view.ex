defmodule SnitchApiWeb.OrderView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView
  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias Snitch.Data.Model.PromotionAdjustment
  alias Snitch.Domain.Order
  alias Snitch.Data.Model.GeneralConfiguration, as: GCModel

  location("/orders/:id")

  attributes([
    :state,
    :user_id,
    :billing_address,
    :shipping_address,
    :number,
    :state,
    :amount,
    :order_total_amount,
    :promo_total,
    :adjustment_total,
    :item_count
  ])

  has_many(
    :line_items,
    serializer: SnitchApiWeb.LineItemView,
    include: false
  )

  has_many(
    :payments,
    serializer: SnitchApiWeb.PaymentView,
    include: false
  )

  has_many(
    :packages,
    serializer: SnitchApiWeb.PackageView,
    include: false
  )

  has_many(
    :promotion_adjustments,
    serializer: SnitchApiWeb.PromoAdjustmentView,
    include: false
  )

  def item_count(order, _) do
    order.line_items
    |> Enum.reduce(0, fn line_item, acc ->
      acc + line_item.quantity
    end)
  end

  def order_total_amount(order, conn) do
    Money.sub!(amount(order, conn), promo_total(order, conn))
  end

  def amount(order, _) do
    Order.total_amount(order)
  end

  ## The function needs to be optimized in terms of db queries.
  def promo_total(struct, _conn) do
    result =
      struct
      |> PromotionAdjustment.eligible_order_adjustments()
      |> Enum.reduce(Decimal.new(0), fn adjustment, acc ->
        adjustment.amount |> Decimal.mult(-1) |> Decimal.add(acc)
      end)

    currency = GCModel.fetch_currency()
    Money.new!(currency, result)
  end

  def line_items(struct, _conn) do
    struct
    |> Repo.preload(:line_items)
    |> Map.get(:line_items)
  end

  def promotion_adjustments(struct, _conn) do
    struct
    |> PromotionAdjustment.eligible_order_adjustments()
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

defmodule SnitchApiWeb.PromoAdjustmentView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  attributes([:id, :label, :amount, :adjustable_type, :adjustable_id])
end
