defmodule Snitch.Domain.Calculator.FlatRate do
  @moduledoc """
  Models the `flate rate calculator`, exposes functionality related to
  it.
  """
  use Snitch.Data.Schema
  alias Snitch.Data.Schema.{LineItem, Order}
  alias Snitch.Domain.Order, as: OrderDomain

  @behaviour Snitch.Domain.Calculator

  @type t :: %__MODULE__{}

  embedded_schema do
    field(:amount, :decimal, default: 0)
  end

  def changeset(%__MODULE__{} = data, params) do
    data
    |> cast(params, [:amount])
    |> validate_required([:amount])
  end

  def compute(%Order{} = order, params) do
    order_total = OrderDomain.total_amount(order)

    case Decimal.cmp(order_total.amount, params.amount) do
      :eq ->
        params.amount

      :gt ->
        params.amount

      _ ->
        order_total.amount
    end
  end

  def compute(%LineItem{} = item, params) do
    item_total = item.unit_price.amount * item.quantity

    case Decimal.cmp(item_total, params.amount) do
      :eq ->
        params.amount

      :gt ->
        params.amount

      _ ->
        item_total
    end
  end
end
