defmodule Snitch.Domain.Calculator.FlatPercent do
  @moduledoc """
  Models the `flat percent calculator` exposes functionality related
  to the same.
  """
  use Snitch.Data.Schema
  alias Snitch.Data.Schema.{LineItem, Order}
  alias Snitch.Domain.Order, as: OrderDomain

  @behaviour Snitch.Domain.Calculator
  @type t :: %__MODULE__{}

  embedded_schema do
    field(:percent_amount, :decimal, default: 0)
  end

  def changeset(%__MODULE__{} = data, params) do
    data
    |> cast(params, [:percent_amount])
    |> validate_required([:percent_amount])
    |> validate_number(:percent_amount, less_than: 100, greater_than: 0)
  end

  # TODO implement the function
  def compute(%Order{} = order, params) do
    order_total = OrderDomain.total_amount(order)

    order_total.amount
    |> Decimal.mult(params.percent_amount)
    |> Decimal.div(100)
  end

  # TODO implement the function
  def compute(%LineItem{} = line_item, params) do
    line_item_total = Money.mult!(line_item.unit_price, line_item.quantity)

    line_item_total.amount
    |> Decimal.mult(params.percent_amount)
    |> Decimal.div(100)
  end
end
