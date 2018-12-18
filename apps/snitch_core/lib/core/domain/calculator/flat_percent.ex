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
    field(:percent_amont, :decimal, default: 0)
  end

  def changeset(%__MODULE__{} = data, params) do
    data
    |> cast(params, [:percent_amount])
    |> validate_required([:percent_amount])
  end

  # TODO implement the function
  def compute(%Order{} = order, params, currency) do
  end

  # TODO implement the function
  def compute(%Order{} = order, params) do
  end
end
