defmodule Snitch.Data.Schema.Order do
  @moduledoc """
  Models an Order
  """

  use Rummage.Ecto
  use Snitch.Data.Schema

  alias Ecto.Nanoid
  alias Snitch.Data.Schema.{LineItem, OrderAddress, Package, Payment, User}

  @type t :: %__MODULE__{}

  schema "snitch_orders" do
    field(:number, Nanoid, autogenerate: true)
    field(:state, :string, default: "cart")
    field(:special_instructions, :string)

    embeds_one(:billing_address, OrderAddress, on_replace: :update)
    embeds_one(:shipping_address, OrderAddress, on_replace: :update)

    # associations
    belongs_to(:user, User)
    has_many(:line_items, LineItem, on_delete: :delete_all, on_replace: :delete)
    has_many(:packages, Package)
    has_many(:payments, Payment)

    timestamps()
  end

  @required_fields ~w(state user_id)a
  @create_fields @required_fields

  @update_fields ~w(state special_instructions)a
  @partial_update_fields @update_fields

  @doc """
  Returns a Order changeset for a "new" order.

  A list of `LineItem` params can be provided under the `:line_items` key, and
  each of those must include price fields, use
  `Snitch.Data.Model.LineItem.update_unit_price/1` if needed.
  > Note that `variant_id`s must be unique in each line item.
  """
  @spec create_changeset(t, map) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = order, params) do
    order
    |> cast(params, @create_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:number)
    |> foreign_key_constraint(:user_id)
    |> cast_assoc(:line_items)
    |> ensure_unique_line_items()
  end

  @doc """
  Returns a Order changeset to update `order`.

  `LineItem` params (if any) must include price fields.
  > Note that `variant_id`s must be unique in each line item.
  """
  @spec update_changeset(t, map) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = order, params) do
    order
    |> cast(params, @update_fields)
    |> cast_assoc(:line_items)
    |> ensure_unique_line_items()
  end

  @doc """
  Returns a Order changeset for a "new" order without a user.

  A list of `LineItem` params can be provided under the `:line_items` key, and
  each of those must include price fields, use
  `Snitch.Data.Model.LineItem.update_unit_price/1` if needed.
  > Note that `variant_id`s must be unique in each line item.

  Suitable for creating orders for guest users.
  """
  @spec create_for_guest_changeset(t, map) :: Ecto.Changeset.t()
  def create_for_guest_changeset(%__MODULE__{} = order, params) do
    order
    |> cast(params, [:state])
    |> validate_required([:state])
    |> unique_constraint(:number)
    |> cast_assoc(:line_items)
    |> ensure_unique_line_items()
  end

  @spec create_guest_changeset(t, map) :: Ecto.Changeset.t()
  def create_guest_changeset(%__MODULE__{} = order, params) do
    order
    |> cast(params, [])
    |> unique_constraint(:number)
    |> common_changeset()
  end

  @doc """
  Returns a Order changeset that does not update line items.

  Use this function to update an order's fields (as opposed to associations like
  `:line_items`).
  """
  @spec partial_update_changeset(t, map) :: Ecto.Changeset.t()
  def partial_update_changeset(%__MODULE__{} = order, params) do
    order
    |> cast(params, @partial_update_fields)
    |> cast_embed(:billing_address)
    |> cast_embed(:shipping_address)
  end

  @spec common_changeset(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp common_changeset(order_changeset) do
    order_changeset
    |> validate_amount(:item_total)
    |> validate_amount(:promo_total)
    |> validate_amount(:adjustment_total)
    |> validate_amount(:total)
  end

  @spec ensure_unique_line_items(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp ensure_unique_line_items(%Ecto.Changeset{valid?: true} = order_changeset) do
    line_item_changesets = get_field(order_changeset, :line_items, [])

    items_are_unique? =
      Enum.reduce_while(line_item_changesets, MapSet.new(), fn item, map_set ->
        v_id = item.product_id

        if MapSet.member?(map_set, v_id) do
          {:halt, false}
        else
          {:cont, MapSet.put(map_set, v_id)}
        end
      end)

    if items_are_unique? do
      order_changeset
    else
      add_error(order_changeset, :line_items, "line_items must have unique variant_ids")
    end
  end

  defp ensure_unique_line_items(order_changeset), do: order_changeset
end
