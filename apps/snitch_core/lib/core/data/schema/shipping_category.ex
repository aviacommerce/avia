defmodule Snitch.Data.Schema.ShippingCategory do
  @moduledoc """
  Models a shipping category that groups Products.
  """

  use Snitch.Data.Schema

  alias Snitch.Data.Schema.{Product}

  @type t :: %__MODULE__{}

  schema "snitch_shipping_categories" do
    field(:name, :string)

    has_many(:products, Product)

    timestamps()
  end

  @create_fields ~w(name)a
  @update_fields ~w(name)a

  @doc """
  Returns a `ShippingCategory` changeset to create a new `shipping_category`.
  """
  @spec create_changeset(__MODULE__.t(), map) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = shipping_category, params) do
    shipping_category
    |> cast(params, @create_fields)
    |> unique_constraint(:name)
  end

  @doc """
  Returns a `ShippingCategory` changeset to update an existing
  `shipping_category`.
  """
  @spec update_changeset(__MODULE__.t(), map) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = shipping_category, params) do
    shipping_category
    |> cast(params, @update_fields)
    |> unique_constraint(:name)
  end
end
