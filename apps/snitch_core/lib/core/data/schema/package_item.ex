defmodule Snitch.Data.Schema.PackageItem do
  @moduledoc """
  Models a PackageItem, a `Package` is composed of many `PackageItem`s.

  ## Fulfillment
  There are two kinds of fulfillments:
  1. `immediate`, there is enough stock "on hand" at the origin stock location.
     - `:backordered` is set to `false`
  2. `deffered`, there is not enough stock "on hand" (possibly even none),
     ***and*** the origin stock location allows backorders on the requested
     variant/product.
     - `:backordered` is set to `true`

  For a detailed explanation of how backorders work, please refer the [guide on
  setting up stock locations](#).

  > The *origin stock location* is the location which would ship the package
    containing this package-item.

  ### Immediate Fulfillment

  If the `:backordered?` field is `false`, the package item immediately fulfills
  the line item.
  This also implies the following:
  ```
  package_item.delta = 0
  ```

  ### Deffered Fulfillment

  If the `:backordered?` field is `true`, the package item _will fulfill_ the
  line item, in the future. The (parent) package cannot be immediately shipped.

  This also implies the following:
  ```
  package_item.delta = package_item.line_item.quantity - currently_on_hand
  ```
  """
  use Snitch.Data.Schema

  alias Snitch.Data.Schema.{Variant, LineItem, Package}

  @typedoc """
  Every fulfilled `LineItem` get shipped in as `PackageItem` in a `Package`.

  ## Fields

  ### `:quantity`

  The number of units (of this item) that are currently "on hand" at the stock
  location. The package can be shipped only when this becomes equal to the
  quantity ordered.
  When the item is immediately fulfilled, this is same as the line_item's
  quantity.
  Otherwise, this is the number of units that are currently "on hand" at the
  origin stock location.

  ### `:delta`

  The difference between the `:quantity` and the number of units "on
  hand".
  """
  @type t :: %__MODULE__{}

  schema "snitch_package_items" do
    field(:number, :string)
    field(:state, :string)
    field(:quantity, :integer)
    field(:delta, :integer)
    field(:backordered?, :boolean)

    belongs_to(:variant, Variant)
    belongs_to(:line_item, LineItem)
    belongs_to(:package, Package)

    has_one(:order, through: [:package, :order])

    timestamps()
  end

  @create_fields ~w(number state delta quantity line_item_id variant_id package_id)a
  @required_fields ~w(number state quantity line_item_id variant_id package_id)a
  @update_fields ~w(state quantity delta)a

  @doc """
  Returns a `PackageItem` changeset to create a new `package_item`.
  """
  @spec create_changeset(t, map) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = package_item, params) do
    package_item
    |> cast(params, @create_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:line_item_id)
    |> foreign_key_constraint(:variant_id)
    |> foreign_key_constraint(:package_id)
    |> unique_constraint(:number)
    |> common_changeset()
  end

  @doc """
  Returns a `PackageItem` changeset to update the `package_item`.
  """
  @spec update_changeset(t, map) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = package_item, params) do
    package_item
    |> cast(params, @update_fields)
    |> common_changeset()
  end

  defp common_changeset(package_item_changeset) do
    package_item_changeset
    |> validate_number(:quantity, greater_than: -1)
    |> validate_number(:delta, greater_than: -1)
    |> validate_backorder_and_delta()
  end

  defp validate_backorder_and_delta(%Ecto.Changeset{valid?: true} = changeset) do
    case fetch_change(changeset, :delta) do
      {:ok, delta} when delta == 0 ->
        put_change(changeset, :backordered?, false)

      {:ok, delta} when delta > 0 ->
        put_change(changeset, :backordered?, true)

      _ ->
        changeset
    end
  end

  defp validate_backorder_and_delta(%Ecto.Changeset{} = cs), do: cs
end
