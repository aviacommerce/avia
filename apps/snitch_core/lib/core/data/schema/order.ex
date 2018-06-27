defmodule Snitch.Data.Schema.Order do
  @moduledoc """
  Models an Order
  """

  use Snitch.Data.Schema

  alias Ecto.Nanoid
  alias Snitch.Data.Model.LineItem, as: LineItemModel
  alias Snitch.Data.Schema.{LineItem, OrderAddress, User}

  @type t :: %__MODULE__{}

  schema "snitch_orders" do
    field(:number, Nanoid, autogenerate: true)
    field(:state, :string, default: "cart")
    field(:special_instructions, :string)
    field(:confirmed?, :boolean, default: false)

    # various prices and totals
    field(:total, Money.Ecto.Composite.Type)
    field(:item_total, Money.Ecto.Composite.Type)
    field(:adjustment_total, Money.Ecto.Composite.Type)
    field(:promo_total, Money.Ecto.Composite.Type)

    embeds_one(:billing_address, OrderAddress, on_replace: :update)
    embeds_one(:shipping_address, OrderAddress, on_replace: :update)

    # associations
    belongs_to(:user, User)
    has_many(:line_items, LineItem, on_delete: :delete_all, on_replace: :delete)

    timestamps()
  end

  @required_fields ~w(state user_id)a
  @create_fields @required_fields

  @update_fields [:state]

  @doc """
  Returns a Order changeset with totals for a "new" order.

  A list of `LineItem` params are expected under the `:line_items` key, and each
  of those must include price fields, use
  `Snitch.Data.Model.LineItem.update_price_and_totals/1` if needed.
  > Note that `variant_id`s must be unique in each line item.
  """
  @spec create_changeset(t, map) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = order, params) do
    order
    |> cast(params, @create_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:number)
    |> foreign_key_constraint(:user_id)
    |> cast_assoc(:line_items, with: &LineItem.create_changeset/2, required: true)
    |> ensure_unique_line_items()
    |> compute_totals()
  end

  @doc """
  Returns a Order changeset with totals to update `order`.

  `LineItem` params (if any) must include price fields.
  > Note that `variant_id`s must be unique in each line item.
  """
  @spec update_changeset(t, map) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = order, params) do
    order
    |> cast(params, @update_fields)
    |> cast_assoc(:line_items, with: &LineItem.create_changeset/2)
    |> ensure_unique_line_items()
    |> compute_totals()
  end

  @spec partial_update_changeset(t, map) :: Ecto.Changeset.t()
  def partial_update_changeset(%__MODULE__{} = order, params) do
    order
    |> cast(params, [:state])
    |> cast_embed(:billing_address)
    |> cast_embed(:shipping_address)
  end

  @spec compute_totals(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp compute_totals(%Ecto.Changeset{valid?: true} = order_changeset) do
    item_total =
      order_changeset
      |> get_field(:line_items)
      |> LineItemModel.compute_total()

    total = Enum.reduce([item_total], &Money.add!/2)

    # TODO: This is only till we have adjustment and promo calculators ready.
    order_changeset
    |> put_change(:item_total, item_total)
    |> put_change(:total, total)
    |> put_change(:adjustment_total, Money.new(0, :USD))
    |> put_change(:promo_total, Money.new(0, :USD))
  end

  defp compute_totals(order_changeset), do: order_changeset

  @spec ensure_unique_line_items(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp ensure_unique_line_items(%Ecto.Changeset{valid?: true} = order_changeset) do
    line_item_changesets = get_field(order_changeset, :line_items)

    items_are_unique? =
      Enum.reduce_while(line_item_changesets, MapSet.new(), fn item, map_set ->
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
