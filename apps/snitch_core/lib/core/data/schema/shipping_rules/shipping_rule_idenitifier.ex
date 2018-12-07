defmodule Snitch.Data.Schema.ShippingRuleIdentifier do
  @moduledoc """
  Models the `idenitifier` that would be used in creating
  the shipping_rules
  """
  use Snitch.Data.Schema
  alias Snitch.Data.Schema.ShippingRule

  @type t :: %__MODULE__{}

  # fso -> free shipping for all orders
  # fsrp -> flat shipping rate for each product
  # fiso -> fixed shipping for order
  # fsro -> free shipping on order above some amount

  @product_identifiers ~w(fsrp)a
  @order_identifiers ~w(fiso fsro fso)a

  schema "snitch_shipping_rule_identifiers" do
    field(:code, Ecto.Atom)
    field(:description, :string)

    timestamps()
  end

  @required_fields ~w(code description)a

  def changeset(%__MODULE__{} = identifier, params) do
    identifier
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:code, identifier_codes())
    |> unique_constraint(:code)
  end

  def codes() do
    identifier_codes()
  end

  def product_identifier() do
    @product_identifiers
  end

  def order_identifiers() do
    @order_identifiers
  end

  def identifer_description(code) do
    case code do
      :fso -> "free shipping for order"
      :fsrp -> "flat shipping rate for each product"
      :fiso -> "fixed shipping rate for order"
      :fsro -> "free shipping on order above amount"
    end
  end

  def identifier_with_module() do
    # Code dynamically creates the below map by looking
    # at all the modules implementing shipping rule behavior.

    # with {:ok, list} <- :application.get_key(:snitch_core, :modules) do
    #   list
    #   |> Enum.filter(fn module ->
    #     ShippingRule in (module.module_info(:attributes)[:behaviour] || [])
    #   end)
    #   |> Enum.reduce(%{}, fn module, acc ->
    #     Map.put(acc, module.identifier(),
    #       %{module: module, description: module.description()})
    #   end)
    # end

    %{
      fso: %{
        description: "free shipping for order",
        module: Snitch.Data.Schema.ShippingRule.OrderFree
      },
      fsoa: %{
        description: "free shipping above specified amount",
        module: Snitch.Data.Schema.ShippingRule.OrderConditionalFree
      },
      fsrp: %{
        description: "fixed shipping rate per product",
        module: Snitch.Data.Schema.ShippingRule.ProductFlatRate
      },
      ofr: %{
        description: "fixed shipping rate for order",
        module: Snitch.Data.Schema.ShippingRule.OrderFlatRate
      }
    }
  end

  def identifier_codes() do
    with {:ok, list} <- :application.get_key(:snitch_core, :modules) do
      list
      |> Enum.filter(fn module ->
        ShippingRule in (module.module_info(:attributes)[:behaviour] || [])
      end)
      |> Enum.reduce([], fn module, acc ->
        [module.identifier() | acc]
      end)
    end
  end
end
