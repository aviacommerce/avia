defmodule Snitch.Data.Schema.PromotionRule.Product do
  @moduledoc """
  Models the `promotion rule` based on products.

  The rule imposes a condition that a set of products specified by the
  rule are present depending on a preference type:
  - `all' should be present.
  - `any` can be present.
  - `none` should be present.
  """

  use Snitch.Data.Schema
  @behaviour Snitch.Data.Schema.PromotionRule

  @type t :: %__MODULE__{}

  @name "Product Rule"

  @match_policy ~w(all any none)s

  embedded_schema do
    field(:product_list, {:array, :integer})
    field(:match_policy, :string)
  end

  @params ~w(product_list match_policy)a

  def changeset(%__MODULE__{} = data, params) do
    data
    |> cast(params, @params)
    |> validate_length(:product_list, min: 1)
    |> validate_inclusion(:match_policy, @match_policy)
  end

  @doc """
  Checks if the promotion rule for product is applicable for the supplied
  order.
  Takes as input the order and the list of products, if any of the products
  in the order are present in the supplied product list then the rule is
  satisfied.
  """
  def eligible(order, rule_data) do
    # TODO add logic here.
  end

  def rule_name() do
    @name
  end
end
