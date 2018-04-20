defmodule Snitch.Data.Schema.Order do
  @moduledoc """
  Models an Order
  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.{Address, User, LineItem}
  alias Snitch.Data.Model.LineItem, as: LineItemModel

  @type t :: %__MODULE__{}

  schema "snitch_orders" do
    field(:slug, :string)
    field(:state, :string, default: "cart")
    field(:special_instructions, :string)
    field(:confirmed?, :boolean, default: false)

    # various prices and totals
    field(:total, Money.Ecto.Composite.Type)
    field(:item_total, Money.Ecto.Composite.Type)
    field(:adjustment_total, Money.Ecto.Composite.Type)
    field(:promo_total, Money.Ecto.Composite.Type)

    # field :shipping
    # field :payment

    # field(:completed_at, :naive_datetime)

    # associations
    belongs_to(:user, User)
    belongs_to(:billing_address, Address)
    belongs_to(:shipping_address, Address)
    has_many(:line_items, LineItem, on_delete: :delete_all, on_replace: :delete)

    timestamps()
  end

  @required_fields ~w(slug state user_id)a
  @optional_fields ~w(billing_address_id shipping_address_id)a

  @doc """
  Returns a complete changeset with totals.

  The `action` field can be either `:create` or `:update`.

  * `:create`
    - A list of `LineItem` params are expected under the `:line_items` key, and
      each of those must include price fields, use
      `Snitch.Data.Model.LineItem.update_price_and_totals/1` if
      needed. Note that `variant_id`s must be unique in each line item.
  * `:update`
    - `LineItem` params (if any) must include price fields.

  ## Note
  The changeset `action` is not set.
  """
  @spec changeset(__MODULE__.t(), map, :create | :update) :: Ecto.Changeset.t()
  def changeset(order, params, action) do
    order
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:billing_address_id)
    |> foreign_key_constraint(:shipping_address_id)
    |> do_changeset(action)
  end

  @spec create_changeset(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp create_changeset(order_changeset) do
    order_changeset
    |> cast_assoc(:line_items, with: &LineItem.create_changeset/2, required: true)
    |> ensure_unique_line_items()
    |> compute_totals()
  end

  @spec update_changeset(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp update_changeset(order_changeset) do
    order_changeset
    |> cast_assoc(:line_items, with: &LineItem.create_changeset/2)
    |> ensure_unique_line_items()
    |> compute_totals()
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

  defp do_changeset(changeset, :create), do: create_changeset(changeset)
  defp do_changeset(changeset, :update), do: update_changeset(changeset)

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
