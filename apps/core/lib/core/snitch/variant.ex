defmodule Core.Snitch.Variant do
  @moduledoc """
  Models a Product variant.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}
  schema "snitch_variants" do
    field(:sku, :string, default: "")
    field(:weight, :integer, precision: 8, scale: 2, default: 0.0)
    field(:height, :integer, precision: 8, scale: 2)
    field(:width, :integer, precision: 8, scale: 2)
    field(:depth, :integer, precision: 8, scale: 2)
    field(:is_master, :boolean, default: false)
    field(:cost_price, :integer, precision: 10, scale: 2)
    field(:position, :integer)
    field(:cost_currency, :string)
    field(:track_inventory, :boolean, default: true)
    field(:discontinue_on, :naive_datetime)

    timestamps()
  end

  @permitted_fields ~w(sku weight height width depth is_master cost_price position cost_currency track_inventory discontinue_on)a

  def changeset(%__MODULE__{} = variant, attrs) do
    variant
    |> cast(attrs, @permitted_fields)

    # Ensures a new variant takes the product master price when price is not supplied
    # Ensure sku's are unique on all records which are not soft deleted
  end
end
