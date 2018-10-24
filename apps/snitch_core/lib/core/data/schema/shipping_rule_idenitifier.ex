defmodule Snitch.Data.Schema.ShippingRuleIdentifier do
  @moduledoc """
  Models the `idenitifier` that would be used in creating
  the shipping_rules
  """
  use Snitch.Data.Schema
  @type t :: %__MODULE__{}

  # fso -> free shipping for all orders
  # fsrp -> flat shipping rate for each product
  # fiso -> fixed shipping for order
  # fsro -> free shipping on order above some amount

  @product_identifiers ~w(fsrp)a
  @order_identifiers ~w(fiso fsro fso)a
  @codes @product_identifiers ++ @order_identifiers

  schema "snitch_shipping_rule_identifiers" do
    field(:code, Ecto.Atom)
    field(:description, :string)

    timestamps()
  end

  @required_fields ~w(code)a
  @optional_fields ~w(description)a ++ @required_fields

  def changeset(%__MODULE__{} = identifier, params) do
    identifier
    |> cast(params, @optional_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:code, @codes)
    |> unique_constraint(:code)
  end

  def codes() do
    @codes
  end

  def product_identifier() do
    @product_identifiers
  end

  def order_identifiers() do
    @order_identifiers
  end
end
