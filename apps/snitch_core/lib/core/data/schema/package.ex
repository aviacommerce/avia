defmodule Snitch.Data.Schema.Package do
  @moduledoc """
  Models a Package which is composed of many `PackageItem`s.
  """
  use Snitch.Data.Schema

  alias Ecto.Nanoid
  alias Snitch.Data.Schema.Embedded.ShippingMethod, as: EmbeddedShippingMethod
  alias Snitch.Data.Schema.{Order, PackageItem, ShippingCategory, ShippingMethod, StockLocation}

  @typedoc """
  A Package that gets shipped to a user.

  Note that both `Package` and `PackageItem` have the `:shipping_tax` field and
  `package.shipping_tax` is NOT the sum of package_item.shipping_tax`.

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

  #### `:shipping_tax`
  The shipping tax on this package. This is different from the taxes on the
  constituent package items. The total shipping tax for a package is thus:
  ```
  total_tax_on_shipping_of_items =
    package.items
    |> Stream.map(fn %{shipping_tax: tax} -> tax end)
    |> Enum.reduce(&Money.add!/2)

  total_shipping_tax = Money.add!(
    package.shipping_tax,
    total_tax_on_shipping_of_items
  )
  ```

  #### `:origin`
  The `StockLocation` where this package originates from.
  """
  @type t :: %__MODULE__{}

  schema "snitch_packages" do
    field(:number, Nanoid, autogenerate: true)
    field(:state, PackageStateEnum)
    field(:shipped_at, :utc_datetime)
    field(:tracking, :map)
    embeds_many(:shipping_methods, EmbeddedShippingMethod, on_replace: :delete)

    field(:cost, Money.Ecto.Composite.Type)
    field(:shipping_tax, Money.Ecto.Composite.Type)

    belongs_to(:order, Order)
    belongs_to(:origin, StockLocation)
    belongs_to(:shipping_category, ShippingCategory)
    belongs_to(:shipping_method, ShippingMethod)

    has_many(:items, PackageItem)

    timestamps()
  end

  @price_fields ~w(cost shipping_tax)a
  @update_fields ~w(state shipped_at tracking shipping_method_id)a ++ @price_fields
  @shipping_fields [:shipping_method_id | @price_fields]

  @create_fields ~w(order_id origin_id shipping_category_id)a ++ @update_fields
  @required_fields ~w(state order_id origin_id shipping_category_id)a

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
  Returns a `Package` changeset to update the `package`.
  """
  @spec update_changeset(t, map) :: Ecto.Changeset.t()
  def update_changeset(package, params) do
    package
    |> cast(params, @update_fields)
    |> cast_embed(:shipping_methods)
    |> common_changeset()
  end

  @doc """
  Returns a `Package` changeset to update the `package`.

  The `:shipping_method`, `:cost` and `shipping_tax` must either be changed via
  `params` or already set previously in the `package`.
  """
  @spec shipping_changeset(t, map) :: Ecto.Changeset.t()
  def shipping_changeset(package, params) do
    package
    |> update_changeset(params)
    |> validate_required(@shipping_fields)
  end

  defp common_changeset(package_changeset) do
    package_changeset
    |> foreign_key_constraint(:shipping_method_id)
    |> validate_amount(:cost)
    |> validate_amount(:shipping_tax)
  end
end
