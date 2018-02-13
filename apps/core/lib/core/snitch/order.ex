defmodule Core.Snitch.Order do
  @moduledoc """
  Models an Order
  """

  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

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
    has_many(:line_items, Core.Snitch.LineItem, on_delete: :delete_all)

    timestamps()
  end

  @required_fields ~w(slug state total user_id billing_address_id shipping_address_id)a
  @optional_fields ~w()a

  @spec changeset(__MODULE__.t(), map()) :: Ecto.Changeset.t()
  def changeset(order, params) do
    order
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:billing_shipping_id)
    |> foreign_key_constraint(:shipping_shipping_id)
  end

  def create_changeset(order, params, line_item_changesets) do
    order
    |> changeset(params)
  end

  def compute_prices(variant_ids) do
    from(v in "snitch_variants", select: v.cost_price, where: v.id in ^variant_ids)
    |> Core.Repo.all()
    |> Stream.map(fn cp ->
      {:ok, cost} = Money.Ecto.Composite.Type.load(cp)
      cost
    end)
    |> Enum.reduce(fn cp1, cp2 ->
      {:ok, sum} = Money.add!(cp1, cp2)
      sum
    end)
  end
end
