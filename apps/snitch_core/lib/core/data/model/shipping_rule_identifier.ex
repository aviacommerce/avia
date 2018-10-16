defmodule Snitch.Data.Model.ShippingRuleIdentifier do
  @moduledoc """
  APIs for shipping rule identifier
  """

  use Snitch.Data.Model
  alias Snitch.Data.Schema.ShippingRuleIdentifier

  @doc """
  Returns all the shipping rule identifiers.
  """
  @spec get_all() :: [ShippingRuleIdentifier.t()]
  def get_all do
    Repo.all(ShippingRuleIdentifier)
  end

  @doc """
  Returns a `shipping rule identifier` by the supplied `id`.
  """
  @spec get(non_neg_integer) :: ShippingRuleIdentifier.t() | nil
  def get(id) do
    QH.get(ShippingRuleIdentifier, id, Repo)
  end
end
