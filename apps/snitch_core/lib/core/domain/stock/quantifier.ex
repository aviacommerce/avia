defmodule Snitch.Domain.Stock.Quantifier do
  @moduledoc """
  Interface for handling inventory related business logic
  """

  use Snitch.Domain
  import Ecto.Changeset
  alias Model.StockItem, as: StockItemModel
  alias Model.Product, as: ProductModel

  @doc """
  Returns a `total available inventory count` for stock items
  present in all active stock locations only.
  """
  @spec total_on_hand(Snitch.Data.Schema.Variant.t() | non_neg_integer()) :: non_neg_integer()
  def total_on_hand(variant) when is_map(variant), do: total_on_hand(variant.id)

  def total_on_hand(variant_id) when is_integer(variant_id) do
    StockItemModel.total_on_hand(variant_id)
  end

  @doc """
  Checks if there are enough stock item on hand for the `product_id`
  and quantity present in the supplied changeset.
  """
  @spec validate_in_stock(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def validate_in_stock(%Ecto.Changeset{valid?: false} = changeset), do: changeset

  def validate_in_stock(%Ecto.Changeset{valid?: true} = changeset) do
    with {_, product_id} <- fetch_field(changeset, :product_id),
         {_, quantity} <- fetch_field(changeset, :quantity),
         {:track_inventory, true} <-
           {:track_inventory, is_inventory_tracking_enabled(product_id)},
         total when quantity <= total and not is_nil(total) <- total_on_hand(product_id) do
      changeset
    else
      {:track_inventory, false} ->
        changeset

      _ ->
        add_error(changeset, :stock, "Stock Insufficient")
    end
  end

  defp is_inventory_tracking_enabled(product_id) do
    {:ok, product} = ProductModel.get(product_id)

    case product.inventory_tracking do
      :none ->
        false

      _ ->
        true
    end
  end
end
