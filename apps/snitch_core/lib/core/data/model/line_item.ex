defmodule Snitch.Data.Model.LineItem do
  @moduledoc """
  LineItem API and utilities.
  """
  use Snitch.Data.Model
  alias Snitch.Data.Schema.{Variant, LineItem}
  alias Snitch.Tools.Money, as: MoneyTools

  @spec get(map) :: LineItem.t() | nil
  def get(query_fields) do
    QH.get(LineItem, query_fields, Repo)
  end

  @spec get_all() :: [LineItem.t()]
  def get_all, do: Repo.all(LineItem)

  @doc """
  Set `:unit_price` and `:total` for many `LineItem` `params`.

  `params` from external sources might not include `unit_price` and `total`,
  this function _can_ compute them and return updated `params`.

  Since it accepts any list of maps, and not validated changesets we might not
  be able to compute said fields. Such items are returned as is in the list.

  ## Note
  Selling prices of all `LineItem`s are fetched from the DB in a single query.

  ## Example
  When `variant_id` is `nil` or does not exist, no update is made.
  ```
  iex> Model.LineItem.update_price_and_totals([%{variant_id: -1, quantity: 2}])
  [%{variant_id: -1, quantity: 2}]
  ```

  When both `variant_id` and `quantity` are valid, update is made.
  ```
  iex> variant = Snitch.Repo.one(Snitch.Data.Schema.Variant)
  iex> variant.selling_price
  #Money<:USD, 14.99000000>
  iex> [priced_item] = Model.LineItem.update_price_and_totals(
  ...>   [%{variant_id: variant.id, quantity: 2}]
  ...> )
  iex> priced_item.total
  #Money<:USD, 29.98000000>
  ```
  """
  @spec update_price_and_totals([map]) :: [map]
  def update_price_and_totals(line_items) do
    unit_selling_prices =
      line_items
      |> Stream.map(&Map.get(&1, :variant_id))
      |> Enum.reject(fn x -> is_nil(x) end)
      |> Variant.get_selling_prices()

    Enum.map(line_items, &set_price_and_total(&1, unit_selling_prices))
  end

  @doc """
  Returns the item total for given `line_items`.

  If the list is empty, the call is delegated to `MoneyTools.zero/1`.
  """
  @spec compute_total([LineItem.t()]) :: Money.t()
  def compute_total([]), do: MoneyTools.zero!()

  def compute_total(line_items) when is_list(line_items) do
    line_items
    |> Stream.map(&Map.fetch!(&1, :total))
    |> Enum.reduce(&Money.add!/2)
    |> Money.reduce()
  end

  @spec set_price_and_total(map, %{non_neg_integer: Money.t()}) :: map
  defp set_price_and_total(line_item, unit_selling_prices) do
    with {:ok, quantity} <- Map.fetch(line_item, :quantity),
         {:ok, variant_id} <- Map.fetch(line_item, :variant_id),
         {:ok, unit_price} <- Map.fetch(unit_selling_prices, variant_id),
         {:ok, total} <- Money.mult(unit_price, quantity) do
      line_item
      |> Map.put(:unit_price, unit_price)
      |> Map.put(:total, total)
    else
      _ -> line_item
    end
  end
end
