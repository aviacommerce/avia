defmodule Snitch.Data.Schema.Variant do
  @moduledoc """
  Models a Product variant.
  """

  use Snitch.Data.Schema
  import Ecto.Query

  alias Snitch.Data.Schema.{StockItem, ShippingCategory}
  alias Money.Ecto.Composite.Type, as: MoneyType
  alias Snitch.Repo

  @type t :: %__MODULE__{}

  schema "snitch_variants" do
    field(:sku, :string)
    field(:weight, :decimal, default: Decimal.new(0))
    field(:height, :decimal, default: Decimal.new(0))
    field(:width, :decimal, default: Decimal.new(0))
    field(:depth, :decimal, default: Decimal.new(0))
    field(:selling_price, MoneyType)
    field(:cost_price, MoneyType)
    field(:position, :integer)
    field(:track_inventory, :boolean, default: true)
    field(:discontinue_on, :utc_datetime)

    has_many(:stock_items, StockItem)
    belongs_to(:shipping_category, ShippingCategory)

    timestamps()
  end

  @cast_fields ~w(sku weight height width depth selling_price shipping_category_id)a ++
                 ~w(cost_price position track_inventory discontinue_on)a
  @required_fields ~w(sku cost_price selling_price)a

  @doc """
  Returns a `Variant` changeset to create a new `variant`.
  """
  @spec create_changeset(__MODULE__.t(), map) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = variant, params) do
    variant
    |> cast(params, @cast_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:sku)
    |> validate_amount(:selling_price)
    |> validate_amount(:cost_price)
    |> validate_future_date(:discontinue_on)

    # |> foreign_key_constraint(:shipping_category)
    # TODO: Put the FK contraint in Product schema
    #
    # Variants has_one shipping category through Products, so we won't be
    # placing a FK constraint here.
  end

  def get_selling_prices(variant_ids) do
    # TODO: move the function to variant model
    query =
      from(v in "snitch_variants", select: [v.id, v.selling_price], where: v.id in ^variant_ids)

    query
    |> Repo.all()
    |> Enum.reduce(%{}, fn [v_id, sp], acc ->
      {:ok, cost} = MoneyType.load(sp)
      Map.put(acc, v_id, cost)
    end)
  end
end
