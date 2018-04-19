defmodule Snitch.Data.Schema.ShippingMethod do
  @moduledoc """
  Models a ShippingMethod that caters to a set of Zones and ShippingCategories.

  A ShippingMethod,
  * may belong to zero or more unique zones.
    > A particular Zone may have none or many ShippingMethods -- a classic
      many-to-many relation.
  * can have both Country and State Zones.
  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.{Zone}

  @type t :: %__MODULE__{}

  schema "snitch_shipping_methods" do
    field(:slug, :string)
    field(:name, :string)
    field(:description, :string)

    many_to_many(
      :zones,
      Zone,
      join_through: "snitch_shipping_methods_zones",
      unique: true,
      on_replace: :delete
    )

    # many_to_many :zones, ShippingCategory, join_through: "snitch_shipping_methods_categories"
    timestamps()
  end

  @create_fields ~w(slug name description)a
  @required_fields @create_fields

  @doc """
  Returns a `ShippingMethod` changeset for a new `shipping_method`.

  The `zones` must be `Snitch.Data.Schema.Zone.t` structs.
  The following fields must be present in `params`: `[#{
    @required_fields
    |> Enum.map(fn x -> ":#{x}" end)
    |> Enum.intersperse(", ")
  }]`
  """
  @spec create_changeset(t, map, [Zone]) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = shipping_method, params, zones) do
    shipping_method
    |> changeset(params, zones)
    |> validate_required(@required_fields)
  end

  @doc """
  Returns a `ShippingMethod` changeset for a new `shipping_method`.

  The `zones` must be `Snitch.Data.Schema.Zone.t` structs, and a full list of
  the desired zone structs is expected.
  """
  @spec update_changeset(t, map, [Zone]) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = shipping_method, params, zones) do
    changeset(shipping_method, params, zones)
  end

  @spec update_changeset(t, map, [Zone]) :: Ecto.Changeset.t()
  defp changeset(%__MODULE__{} = shipping_method, params, zones) do
    shipping_method
    |> cast(params, @create_fields)
    |> unique_constraint(:slug)
    |> put_assoc(:zones, zones)
  end
end
