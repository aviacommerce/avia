defmodule Snitch.Domain.Order do
  @moduledoc """
  Order helpers
  """

  use Snitch.Domain

  alias Ecto.Changeset
  alias Snitch.Data.Model.LineItem
  alias Snitch.Data.Schema.Order
  alias Snitch.Tools.Money, as: MoneyTools

  @spec add_line_item(Order.t(), LineItem.t()) :: {:ok, Order.t()} | {:error, term}
  def add_line_item(%Order{state: "cart"} = order, _), do: {:ok, order}

  @spec update_line_item(Order.t(), LineItem.t()) :: {:ok, Order.t()} | {:error, term}
  def update_line_item(%Order{state: "cart"} = order, _), do: {:ok, order}

  @spec remove_line_item(Order.t(), LineItem.t()) :: {:ok, Order.t()} | {:error, term}
  def remove_line_item(%Order{state: "cart"} = order, _), do: {:ok, order}

  @spec compute_taxes_changeset(Changeset.t()) :: Changeset.t()
  def compute_taxes_changeset(%Changeset{valid?: false} = changeset), do: changeset

  def compute_taxes_changeset(%Changeset{valid?: true, data: %Order{} = o} = changeset) do
    order = Repo.preload(o, :line_items)
    item_total = LineItem.compute_total(order.line_items)

    # TODO: Use order.billing_address and order.shipping_address
    tax_total = MoneyTools.zero!()

    changeset
    |> Changeset.put_change(:item_total, item_total)
    |> Changeset.put_change(:tax_total, tax_total)
    |> Changeset.put_change(:total, Money.add!(tax_total, item_total))
  end
end
