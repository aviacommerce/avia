defmodule Core.Snitch.LineItem do
  @moduledoc """
  Models a LineItem

  ## Example

  To build an order, first `build/2` the LineItem changesets and compute their
  totals.

  ```
  line_items = [LineItem.build(1, 3), LineItem.build(2, 1)]
  {product_total, changesets} = LineItem.compute_prices(line_items)
  ```
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
  @optional_fields ~w()a

  @spec create_changeset(__MODULE__.t(), map()) :: Ecto.Changeset.t()
  @doc """
  Returns a `LineItem` changeset without `:total`.

  Do not persist this to DB since price fields are not set! To set prices see
  `price_changeset/2` and `compute_prices/1`.
  """
  def create_changeset(line_item, params) do
    line_item
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_number(:quantity, greater_than: 0)
    |> foreign_key_constraint(:variant_id)
    |> foreign_key_constraint(:order_id)
  end

  @doc """
  Computes and "puts" the total for the changeset using the `unit_price`.

  The `quantity` is fetched via `Ecto.Changeset.fetch_field`, which falls back
  on "old" quantity if there is no change in quantity.

  ## Note
  This function will not fetch the selling price of the variant from DB. Use
  `compute_prices/1` instead.
  """
  def price_changeset(line_item_changeset, unit_price) do
    {_, quantity} = fetch_field(line_item_changeset, :quantity)
    total = Money.mult!(unit_price, quantity)

    line_item_changeset
    |> put_change(:unit_price, unit_price)
    |> put_change(:total, total)
  end

  @doc """
  Returns a `LineItem` changeset without computing `:total`.

  > Equivalent to `create_changeset/2`, but more explicit in arguments.
  """
  @spec build(non_neg_integer(), non_neg_integer()) :: Ecto.Changeset.t()
  def build(variant_id, quantity) do
    %__MODULE__{}
    |> create_changeset(%{variant_id: variant_id, quantity: quantity})
  end

  @doc """
  Returns a `LineItem` changeset and also computes the price.

  This is a costly operation!
  """
  @spec build!(non_neg_integer(), non_neg_integer()) :: Ecto.Changeset.t()
  def build!(variant_id, quantity) do
    line_item = build(variant_id, quantity)
    {_, line_item_with_price} = compute_prices([line_item])
    line_item_with_price
  end

  @doc """
  Compute prices of many `LineItem` changesets in a single DB query.

  Fetching the selling price of all LineItems together from the DB makes it
  faster to compute the order total than using `build!/2` on each LineItem of
  the Order.
  """
  @spec compute_prices([Ecto.Changeset.t()]) :: {product_total :: Money.t(), [Ecto.Changeset.t()]}
  def compute_prices(line_item_changesets) do
    variant_ids = Enum.map(line_item_changesets, fn x -> x.changes.variant_id end)
    unit_prices = Core.Snitch.Variant.get_selling_prices(variant_ids)

    priced_changesets =
      line_item_changesets
      |> Stream.zip(unit_prices)
      |> Enum.map(fn {changeset, unit_selling_price} ->
        price_changeset(changeset, unit_selling_price)
      end)

    product_total =
      priced_changesets
      |> Stream.map(fn x -> x.changes.total end)
      |> Enum.reduce(&Money.add!/2)

    {product_total, priced_changesets}
  end
end
