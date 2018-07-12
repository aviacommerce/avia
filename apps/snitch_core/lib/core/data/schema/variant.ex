defmodule Snitch.Data.Schema.Variant do
  @moduledoc """
  Models a Product variant.
  """

  use Snitch.Data.Schema

  alias Money.Ecto.Composite.Type, as: MoneyType
  alias Snitch.Data.Schema.{Image, Product, ShippingCategory, StockItem}

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
    belongs_to(:product, Product)

    many_to_many(:images, Image, join_through: "snitch_variant_images")

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
end
