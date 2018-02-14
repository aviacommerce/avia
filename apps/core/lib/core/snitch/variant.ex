defmodule Core.Snitch.Variant do
  @moduledoc """
  Models a Product variant.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}
  schema "snitch_variants" do
    field(:sku, :string, default: "")
    field(:weight, :decimal, default: Decimal.new(0))
    field(:height, :decimal)
    field(:width, :decimal)
    field(:depth, :decimal)
    field(:is_master, :boolean, default: false)
    field(:cost_price, Money.Ecto.Composite.Type)
    field(:position, :integer)
    field(:track_inventory, :boolean, default: true)
    field(:discontinue_on, :naive_datetime)

    timestamps()
  end

  @permitted_fields ~w(sku weight height width depth is_master cost_price position track_inventory discontinue_on)a

  def changeset(%__MODULE__{} = variant, attrs) do
    variant
    |> cast(attrs, @permitted_fields)
    |> unique_constraint(:sku)

    # Ensures a new variant takes the product master price when price is not supplied
    # Ensure variants? are not soft deleted
  end
end
