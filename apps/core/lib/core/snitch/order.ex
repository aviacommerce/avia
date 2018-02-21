defmodule Core.Snitch.Order do
  @moduledoc """
  Models an Order
  """

  use Ecto.Schema

  alias Core.Snitch.{LineItem}

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "snitch_orders" do
    field(:slug, :string)
    field(:state, :string, default: "cart")
    field(:special_instructions, :string)
    field(:confirmed?, :boolean, default: false)

    # various prices and totals
    field(:total, Money.Ecto.Composite.Type, default: Money.new(0, :USD))
    field(:item_total, Money.Ecto.Composite.Type, default: Money.new(0, :USD))
    field(:adjustment_total, Money.Ecto.Composite.Type, default: Money.new(0, :USD))
    field(:promo_total, Money.Ecto.Composite.Type, default: Money.new(0, :USD))

    # field :shipping
    # field :payment

    field(:completed_at, :naive_datetime)

    # associations
    belongs_to(:user, Core.Snitch.User)
    belongs_to(:billing_address, Core.Snitch.Address)
    belongs_to(:shipping_address, Core.Snitch.Address)
    has_many(:line_items, Core.Snitch.LineItem, on_delete: :delete_all, on_replace: :delete)

    timestamps()
  end

  @required_fields ~w(slug state user_id billing_address_id shipping_address_id)a
  @optional_fields ~w()a

  @spec changeset(__MODULE__.t(), map()) :: Ecto.Changeset.t()
  defp changeset(order, params) do
    order
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:billing_address_id)
    |> foreign_key_constraint(:shipping_address_id)
  end

  def create_changeset(order, params) do
    order
    |> changeset(params)
    |> validate_required([:line_items])
    |> cast_assoc(:line_items, with: &LineItem.create_changeset/2)
    |> ensure_unique_line_items()
    |> compute_totals()
  end

  def compute_totals(%Ecto.Changeset{valid?: true} = order_changeset) do
    item_total =
      order_changeset
      |> get_field(:line_items, [])
      |> Stream.map(&Map.fetch!(&1, :total))
      |> Enum.reduce(&Money.add!/2)
      |> Money.reduce()

    total = Enum.reduce([item_total], &Money.add!/2)

    order_changeset
    |> put_change(:item_total, item_total)
    |> put_change(:total, total)
  end

  def compute_totals(order_changeset), do: order_changeset

  defp ensure_unique_line_items(%Ecto.Changeset{valid?: true} = order_changeset) do
    line_item_changesets = get_field(order_changeset, :line_items)

    items_are_unique? =
      line_item_changesets
      |> Enum.reduce_while(MapSet.new(), fn item, map_set ->
        v_id = item.variant_id

        if MapSet.member?(map_set, v_id) do
          {:halt, false}
        else
          {:cont, MapSet.put(map_set, v_id)}
        end
      end)

    if items_are_unique? do
      order_changeset
    else
      add_error(order_changeset, :duplicate_variants, "line_items must have unique variant_ids")
    end
  end

  defp ensure_unique_line_items(order_changeset), do: order_changeset
end

# item_total =
#   priced_changesets
#   |> Stream.map(fn x -> {_, total} = fetch_field(x, :total)
#   total
# end)
# |> Enum.reduce(&Money.add!/2)

#   order_changeset
#   |> put_change(:item_total, item_total)
