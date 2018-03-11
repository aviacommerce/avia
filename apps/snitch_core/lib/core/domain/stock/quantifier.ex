defmodule Snitch.Domain.Stock.Quantifier do
  @moduledoc """
  Interface for handling inventory related business logic
  """

  use Snitch.Domain
  alias Model.StockItem, as: StockItemModel

  @doc """
  Returns a `total available inventory count` for stock items
  present in all active stock locations only.
  """
  @spec total_on_hand(Snitch.Data.Schema.Variant.t() | non_neg_integer()) :: non_neg_integer()
  def total_on_hand(variant) when is_map(variant), do: total_on_hand(variant.id)

  def total_on_hand(variant_id) when is_integer(variant_id) do
    StockItemModel.total_on_hand(variant_id)
  end
end
