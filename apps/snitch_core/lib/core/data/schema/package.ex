defmodule Snitch.Data.Schema.Package do
  @moduledoc """
  Models a Package which is composed of many `PackageItem`s.
  """
  use Snitch.Data.Schema

  alias Ecto.Nanoid
  alias Snitch.Data.Schema.Embedded.ShippingMethod, as: EmbeddedShippingMethod
  alias Snitch.Data.Schema.{Order, PackageItem, ShippingCategory, ShippingMethod, StockLocation}

  @typedoc """
  A Package gets shipped to a user.

  The money fields are used to accurately determine taxes and generate shipping
  labels.

  ## Fields

  #### `:tracking`
  This can be any `map` containing information to track the package and its
  shipment.

  #### `:shipping_method`
  The `ShippingMethod` chosen for this package by the user, not to be confused
  with the `:shipping_methods` field!

  #### `:shipping_methods`
  The `ShippingMethod`s and their estimated costs, the user chooses one of them
  and the choice is then stored in `:shipping_method`.

  #### `:cost`
  The shipping cost for the chosen `:shipping_method`.

  #### `:*_total`
  These totals are shipping related, and are applied _over the_ `:cost`.

  #### `:origin`
  The `StockLocation` where this package originates from.
  """
  @type t :: %__MODULE__{}

  schema "snitch_packages" do
    field(:number, Nanoid, autogenerate: true)
    field(:state, :string)
    field(:shipped_at, :utc_datetime)
    field(:tracking, :map)
    embeds_many(:shipping_methods, EmbeddedShippingMethod, on_replace: :delete)

    field(:cost, Money.Ecto.Composite.Type)
    field(:total, Money.Ecto.Composite.Type)
    field(:tax_total, Money.Ecto.Composite.Type)
    field(:adjustment_total, Money.Ecto.Composite.Type)
    field(:promo_total, Money.Ecto.Composite.Type)

    belongs_to(:order, Order)
    belongs_to(:origin, StockLocation)
    belongs_to(:shipping_category, ShippingCategory)
    belongs_to(:shipping_method, ShippingMethod)

    has_many(:items, PackageItem)
    has_one(:address, through: [:order, :shipping_address])

    timestamps()
  end

  @update_fields ~w(state shipped_at tracking shipping_method_id)a ++
                   ~w(cost tax_total adjustment_total promo_total total)a

  @create_fields ~w(number order_id origin_id shipping_category_id)a ++ @update_fields

  @required_fields ~w(number state order_id origin_id shipping_category_id)a

  @doc """
  Returns a `Package` changeset to create a new package.

  A list of `PackageItem` params can be provided under the `:items` key.

  > Note that the `:items` must be plain `map`s and not `struct`s.
  """
  @spec create_changeset(t, map) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = package, params) do
    package
    |> cast(params, @create_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:order_id)
    |> foreign_key_constraint(:origin_id)
    |> foreign_key_constraint(:shipping_category_id)
    |> unique_constraint(:number)
    |> cast_assoc(:items, with: &PackageItem.create_changeset/2)
    |> cast_embed(:shipping_methods, required: true)
    |> common_changeset()
  end

  @doc """
  Returns a `Package` changeset to create a new package.
  """
  @spec update_changeset(t, map) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = package, params) do
    package
    |> cast(params, @update_fields)
    |> cast_embed(:shipping_methods)
    |> common_changeset()
  end

  defp common_changeset(package_changeset) do
    package_changeset
    |> foreign_key_constraint(:shipping_method_id)
    |> validate_amount(:cost)
    |> validate_amount(:tax_total)
  end
end
