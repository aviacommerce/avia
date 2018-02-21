defmodule Core.Snitch.LineItem do
  @moduledoc """
  Models a LineItem.
  """

  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "snitch_line_items" do
    field(:quantity, :integer)
    field(:unit_price, Money.Ecto.Composite.Type)
    field(:total, Money.Ecto.Composite.Type)

    belongs_to(:variant, Core.Snitch.Variant)
    belongs_to(:order, Core.Snitch.Order)
    timestamps()
  end

  @required_fields ~w(quantity variant_id)a
  @optional_fields ~w(unit_price total)a

  @doc """
  Returns a `LineItem` changeset without `:total`.

  Do not persist this to DB since price fields and order are not set! To set
  prices see `update_totals/1` and `create_changeset/2`.
  """
  @spec changeset(__MODULE__.t(), map()) :: Ecto.Changeset.t()
  def changeset(line_item, params) do
    line_item
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_number(:quantity, greater_than: 0)
    |> foreign_key_constraint(:variant_id)
    |> foreign_key_constraint(:order_id)
  end

  @doc """
  Returns a `LineItem` changeset that can be used for `insert`/`update`.
  """
  @spec create_changeset(__MODULE__.t(), map()) :: Ecto.Changeset.t()
  def create_changeset(line_item, params) do
    line_item
    |> changeset(params)
    |> validate_required(@optional_fields)
  end

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
  iex> LineItem.update_price_and_totals([%{variant_id: -1, quantity: 2}])
  [%{variant_id: -1, quantity: 2}]
  ```

  When both `variant_id` and `quantity` are valid, update is made.
  ```
  iex> variant = Core.Repo.one(Core.Snitch.Variant)
  iex> variant.cost_price
  #Money<:USD, 9.99000000>
  iex> [priced_item] = LineItem.update_price_and_totals(
  ...>   [%{variant_id: variant.id, quantity: 2}]
  ...> )
  iex> priced_item.total
  #Money<:USD, 19.98000000>
  ```
  """
  @spec update_price_and_totals([map()]) :: [map()]
  def update_price_and_totals(line_items) do
    unit_selling_prices =
      line_items
      |> Stream.map(&Map.get(&1, :variant_id))
      |> Enum.reject(fn x -> is_nil(x) end)
      |> Core.Snitch.Variant.get_selling_prices()

    line_items
    |> Enum.map(&set_price_and_total(&1, unit_selling_prices))
  end

  @spec set_price_and_total(map(), %{non_neg_integer: Money.t()}) :: map()
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
