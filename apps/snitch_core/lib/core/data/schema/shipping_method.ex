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
  alias Snitch.Data.Schema.{ShippingCategory, Zone}

  @type t :: %__MODULE__{}

  schema "snitch_shipping_methods" do
    field(:slug, :string)
    field(:name, :string)
    field(:description, :string)

    many_to_many(
      :zones,
      Zone,
      join_through: "snitch_shipping_methods_zones",
      on_replace: :delete,
      # Also set in migrations
      unique: true,
      # Also set in migrations
      on_delete: :delete_all
    )

    many_to_many(
      :shipping_categories,
      ShippingCategory,
      join_through: "snitch_shipping_methods_categories",
      on_replace: :delete,
      # Also set in migrations
      unique: true,
      # Also set in migrations
      on_delete: :delete_all
    )

    timestamps()
  end

  @create_fields ~w(slug name)a
  @cast_fields [:description | @create_fields]

  @doc """
  Returns a `ShippingMethod` changeset for a new `shipping_method`.

  The `zones` must be `Snitch.Data.Schema.Zone.t` structs.
  The `categories` must be `Snitch.Data.Schema.ShippingCategory.t` structs.

  The following fields must be present in `params`: `[#{
    @create_fields
    |> Enum.map(fn x -> ":#{x}" end)
    |> Enum.intersperse(", ")
  }]`
  """
  @spec create_changeset(t, map, [Zone.t()], [ShippingCategory.t()]) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = shipping_method, params, zones, categories) do
    shipping_method
    |> changeset(params, zones, categories)
    |> validate_required(@create_fields)
  end

  @doc """
  Returns a `ShippingMethod` changeset to update an existing `shipping_method`.

  The `zones` must be `Snitch.Data.Schema.Zone.t` structs, and a full list of
  The `categories` must be `Snitch.Data.Schema.ShippingCategory.t` structs.

  The desired zone and category structs are expected. Also see
  `Ecto.Changeset.put_assoc/4`.
  """
  @spec update_changeset(t, map, [Zone.t()], [ShippingCategory.t()]) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = shipping_method, params, zones, categories) do
    changeset(shipping_method, params, zones, categories)
  end

  @spec changeset(t, map, [Zone.t()], [ShippingCategory.t()]) :: Ecto.Changeset.t()
  defp changeset(%__MODULE__{} = shipping_method, params, zones, categories) do
    shipping_method
    |> cast(params, @cast_fields)
    |> unique_constraint(:slug)
    |> put_assoc(:zones, zones)
    |> put_assoc(:shipping_categories, categories)
  end
end

defmodule Snitch.Data.Schema.Embedded.ShippingMethod do
  @moduledoc """
  Defines an embedded schema for `ShippingMethod`.
  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.ShippingMethod

  @type t :: %__MODULE__{}

  @primary_key false
  embedded_schema do
    field(:id, :integer)
    field(:slug, :string)
    field(:name, :string)
    field(:description, :string)
    field(:cost, Money.Ecto.Composite.Type)
  end

  @update_fields ~w(cost)a
  @create_fields @update_fields ++ ~w(id slug name description)a

  def changeset(%__MODULE__{} = embedded_sm, %ShippingMethod{} = sm) do
    changeset(embedded_sm, Map.from_struct(sm))
  end

  def changeset(%__MODULE__{} = embedded_sm, params) do
    embedded_sm
    |> cast(params, @create_fields)
    |> force_money()

    # |> validate_amount(:cost)
  end

  defp force_money(changeset) do
    case fetch_change(changeset, :cost) do
      {:ok, %{amount: amount, currency: currency}} ->
        put_change(changeset, :cost, %{amount: amount, currency: currency})

      _ ->
        changeset
    end
  end
end
