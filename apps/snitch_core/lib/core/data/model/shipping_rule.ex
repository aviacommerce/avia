defmodule Snitch.Data.Model.ShippingRule do
  @moduledoc """
  APIs for shipping rule
  """

  use Snitch.Data.Model

  alias Snitch.Data.Schema.{
    ShippingRule,
    ShippingCategory,
    ShippingRuleIdentifier
  }

  @doc """
  Returns all the shipping rules.
  """
  @spec get_all() :: [ShippingRule.t()]
  def get_all do
    Repo.all(ShippingRule)
    |> Repo.preload([:shipping_category, :shipping_rule_identifier])
  end

  @doc """
  Returns a `shipping rule` by the supplied `id`.
  """
  @spec get(non_neg_integer) :: {:ok, ShippingRule.t()} | {:error, atom}
  def get(id) do
    with {:ok, shipping_rule} <- QH.get(ShippingRule, id, Repo) do
      shipping_rule |> Repo.preload([:shipping_category, :shipping_rule_identifier])
      {:ok, shipping_rule}
    end
  end

  def get_all_by_shipping_category(category_id) do
    ShippingRule
    |> where([sr], sr.shipping_category_id == ^category_id)
    |> Repo.all()
    |> Repo.preload([:shipping_category, :shipping_rule_identifier])
  end
end
