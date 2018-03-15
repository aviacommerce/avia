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
  Returns a ShippingMethod changeset depending on `action`

  If the `action` is `:create`, `[#{
    @required_fields
    |> Enum.map(fn x -> ":#{x}" end)
    |> Enum.intersperse(", ")
  }]`
  are required.

  The `zones` must be `Snitch.Data.Schema.Zone.t` structs. Even if `action` is
  `:update` a full list of the desired zone structs is expected.
  """
  @spec changeset(t, %{}, [Zone], :create | :update) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = shipping_method, params, zones, :create) do
    shipping_method
    |> common_changeset(params, zones)
    |> validate_required(@required_fields)
  end

  def changeset(%__MODULE__{} = shipping_method, params, zones, :update) do
    common_changeset(shipping_method, params, zones)
  end

  defp common_changeset(%__MODULE__{} = shipping_method, params, zones) do
    shipping_method
    |> cast(params, @create_fields)
    |> unique_constraint(:slug)
    |> put_assoc(:zones, zones)
  end
end
