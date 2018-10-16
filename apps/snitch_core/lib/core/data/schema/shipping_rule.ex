defmodule Snitch.Data.Schema.ShippingRule do
  @moduledoc """
  Models the rules to be used while calculating shipping cost for
  a shipping category.
  """

  use Snitch.Data.Schema

  alias Snitch.Data.Schema.{ShippingCategory, ShippingRuleIdentifier}

  @type t :: %__MODULE__{}

  schema "snitch_shipping_rules" do
    field(:lower_limit, :decimal)
    field(:upper_limit, :decimal)
    field(:shipping_cost, Money.Ecto.Composite.Type)
    field(:active?, :boolean, default: false)

    # associations
    belongs_to(:shipping_rule_identifier, ShippingRuleIdentifier)
    belongs_to(:shipping_category, ShippingCategory)

    timestamps()
  end

  @required_fields ~w(shipping_rule_identifier_id shipping_category_id shipping_cost)a
  @optional_fields ~w(lower_limit upper_limit active?)a ++ @required_fields

  def changeset(%__MODULE__{} = rule, params) do
    rule
    |> cast(params, @optional_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:shipping_rule_identifier_id)
    |> foreign_key_constraint(:shipping_category_id)
    |> unique_constraint(:unique_identifier_for_category,
      name: :unique_rule_per_category_for_identifier
    )
  end
end
