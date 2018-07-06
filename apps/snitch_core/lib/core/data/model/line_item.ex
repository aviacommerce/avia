defmodule Snitch.Data.Model.LineItem do
  @moduledoc """
  LineItem API and utilities.
  """
  use Snitch.Data.Model

  alias Ecto.Multi
  alias Snitch.Data.Model.Order, as: OrderModel
  alias Snitch.Data.Model.Variant
  alias Snitch.Data.Schema.{LineItem}
  alias Snitch.Domain.Order, as: OrderDomain
  alias Snitch.Tools.Money, as: MoneyTools

  @doc """
  Creates a new `line_item` for an existing order referenced by `params.order_id`.

  This may also update some associated entities like, `Order`, `Package`,
  etc. in the same DB transaction.

  Returns the newly inserted `line_item` with the order, and all line items preloaded.
  Other updated associations may or may not be preloaded.
  """
  @spec create(map) :: LineItem.t()
  def create(params) do
    Multi.new()
    |> Multi.insert(:line_item, LineItem.create_changeset(%LineItem{}, params))
    |> fetch_order([:line_items])
    |> update_order(&OrderDomain.add_line_item/2)
    |> do_operation()
  end

  @doc """
  Updates `line_item`, and possibly other associations in the same DB transaction.

  Returns the newly inserted `line_item` with the order and all line items preloaded.
  Other updated associations may or may not be preloaded.
  """
  @spec update(LineItem.t(), map) :: LineItem.t()
  def update(%LineItem{} = line_item, params) do
    Multi.new()
    |> Multi.update(:line_item, LineItem.update_changeset(line_item, params))
    |> fetch_order([:line_items])
    |> update_order(&OrderDomain.update_line_item/2)
    |> do_operation()
  end

  @doc """
  Deletes `line_item`, and possibly updates other associations in the same DB transaction.

  Returns the deleted `line_item` with the order and all line items preloaded.
  > The deleted line item will not be in the assoc list.

  Other updated associations may or may not be preloaded.
  """
  @spec delete(LineItem.t()) :: LineItem.t()
  def delete(%LineItem{} = line_item) do
    Multi.new()
    |> Multi.delete(:line_item, line_item)
    |> fetch_order([:line_items])
    |> update_order(&OrderDomain.remove_line_item/2)
    |> do_operation()
  end

  @spec get(map) :: LineItem.t() | nil
  def get(query_fields) do
    QH.get(LineItem, query_fields, Repo)
  end

  @spec get_all() :: [LineItem.t()]
  def get_all, do: Repo.all(LineItem)

  @doc """
  Set `:unit_price` for many `LineItem` `params`.

  `params` from external sources might not include `unit_price`, this function
  _can_ compute it and return updated `params`.

  Since it accepts any list of maps, and not validated changesets we might not
  be able to compute said fields. Such items are returned as is in the list.

  ## Note
  Selling prices of all `LineItem`s are fetched from the DB in a single query.

  ## Example
  When `variant_id` is `nil` or does not exist, no update is made.
  ```
  iex> Model.LineItem.update_unit_price([%{variant_id: -1, quantity: 2}])
  [%{variant_id: -1, quantity: 2}]
  ```

  ```
  iex> variant = Snitch.Repo.one(Snitch.Data.Schema.Variant)
  iex> variant.selling_price
  #Money<:USD, 14.99000000>
  iex> [priced_item] = Model.LineItem.update_unit_price(
  ...>   [%{variant_id: variant.id, quantity: 2}]
  ...> )
  iex> priced_item.unit_price
  #Money<:USD, 14.99000000>
  ```
  """
  @spec update_unit_price([map]) :: [map]
  def update_unit_price([]), do: []

  def update_unit_price(line_items) do
    unit_selling_prices =
      line_items
      |> Stream.map(&Map.get(&1, :variant_id))
      |> Enum.reject(fn x -> is_nil(x) end)
      |> Variant.get_selling_prices()

    Enum.map(line_items, &set_price_and_total(&1, unit_selling_prices))
  end

  @doc """
  Returns the item total for given `line_items`.

  If the list is empty, the call is delegated to `MoneyTools.zero!/1`.
  """
  @spec compute_total([LineItem.t()]) :: Money.t()
  def compute_total([]), do: MoneyTools.zero!()

  def compute_total(line_items) when is_list(line_items) do
    line_items
    |> Stream.map(fn %{quantity: q, unit_price: price} ->
      Money.mult!(price, q)
    end)
    |> Enum.reduce(&Money.add!/2)
    |> Money.reduce()
  end

  @spec set_price_and_total(map, %{non_neg_integer: Money.t()}) :: map
  defp set_price_and_total(line_item, unit_selling_prices) do
    with {:ok, variant_id} <- Map.fetch(line_item, :variant_id),
         {:ok, unit_price} <- Map.fetch(unit_selling_prices, variant_id) do
      Map.put(line_item, :unit_price, unit_price)
    else
      _ -> line_item
    end
  end

  defp fetch_order(multi, preloads \\ []) do
    Multi.run(multi, :fetch_order, fn %{line_item: li} ->
      {:ok, Repo.preload(OrderModel.get(li.order_id), preloads)}
    end)
  end

  defp update_order(multi, updater_fn) do
    Multi.run(multi, :order, fn %{line_item: line_item, fetch_order: order} ->
      updater_fn.(order, line_item)
    end)
  end

  @spec do_operation(Ecto.Multi.t()) :: LineItem.t()
  defp do_operation(multi) do
    multi
    |> Repo.transaction()
    |> case do
      {:ok, %{line_item: line_item, order: order}} ->
        {:ok, struct(line_item, order: order)}

      error ->
        error
    end
  end
end
