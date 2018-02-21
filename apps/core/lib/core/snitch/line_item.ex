defmodule Core.Snitch.LineItem do
  @moduledoc """
  Models a LineItem
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

  @spec create_changeset(__MODULE__.t(), map()) :: Ecto.Changeset.t()
  @doc """
  Returns a `LineItem` changeset without `:total`.

  Do not persist this to DB since price fields and order are not set! To set
  prices see `price_and_total_changeset/2` and `update_totals/1`.
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
  `update_totals/1` instead.
  """
  defp price_and_total_changeset(line_item_changeset, unit_price) do
    {_, quantity} = fetch_field(line_item_changeset, :quantity)
    total = Money.mult!(unit_price, quantity)

    line_item_changeset
    |> put_change(:unit_price, unit_price)
    |> put_change(:total, total)
  end

  @doc """
  Computes and puts prices of all "changed" `LineItem`s in an `Order` changeset.

  This function only looks at the `:line_items` under `:changes`, and is
  guaranteed to return the totals for the new `:line_items`.

  `:total` for each `LineItem` and the `:item_total` of `Order is updated.

  Selling prices of all `LineItem`s are fetched together from the DB.
  """
  @spec update_totals(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def update_totals(%Ecto.Changeset{valid?: true} = order_changeset) do
    {:ok, line_item_changesets} = fetch_change(order_changeset, :line_items)

    variant_ids =
      Enum.map(line_item_changesets, fn x ->
        {_, variant_id} = fetch_field(x, :variant_id)
        variant_id
      end)

    unit_prices = Core.Snitch.Variant.get_selling_prices(variant_ids)

    priced_changesets =
      line_item_changesets
      |> Stream.zip(unit_prices)
      |> Enum.map(fn {changeset, unit_selling_price} ->
        price_and_total_changeset(changeset, unit_selling_price)
      end)

    item_total =
      priced_changesets
      |> Stream.map(fn x -> x.changes.total end)
      |> Enum.reduce(&Money.add!/2)

    order_changeset
    |> put_change(:item_total, item_total)
    |> put_change(:line_items, priced_changesets)
  end

  def update_totals(order_changeset) do
    order_changeset
    |> add_error(:invalid_line_items, "could not compute product totals")
  end
end
