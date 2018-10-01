defmodule Snitch.Data.Schema.ProductProperty do
  @moduledoc """
  Models a ProductProperty.
  """
  use Snitch.Data.Schema

  alias Snitch.Data.Schema.{
    Product,
    Property
  }

  @typedoc """
  ProductProperty struct.

  ## Fields

  * `product_id` uniquely determines `Property` for `Product`
  """
  @type t :: %__MODULE__{}

  schema "snitch_product_properties" do
    belongs_to(:product, Product)
    belongs_to(:property, Property)
    field(:value, :string, null: false)
    timestamps()
  end

  @update_fields ~w(property_id value)a
  @create_fields [:product_id | @update_fields]

  @doc """
  Returns a `ProductProperty` changeset to create a new `snitch_product_properties`.
  """
  @spec create_changeset(t, map) :: Ecto.Changeset.t()
  def create_changeset(snitch_product_property, params) do
    snitch_product_property
    |> cast(params, @create_fields)
    |> validate_required(@create_fields)
    |> foreign_key_constraint(:product_id)
    |> unique_constraint(:property_id, name: :unique_property_per_product)
    |> foreign_key_constraint(:property_id)
  end

  @doc """
  Returns a `ProductProperty` changeset to update the `snitch_product_properties`.
  """
  @spec update_changeset(t, map) :: Ecto.Changeset.t()
  def update_changeset(snitch_product_property, params) do
    snitch_product_property
    |> cast(params, @update_fields)
    |> validate_required(@update_fields)
    |> foreign_key_constraint(:product_id)
    |> unique_constraint(:property_id, name: :unique_property_per_product)
    |> foreign_key_constraint(:property_id)
  end
end
