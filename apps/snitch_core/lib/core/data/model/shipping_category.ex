defmodule Snitch.Data.Model.ShippingCategory do
  @moduledoc """
  APIs `ShippingCategory` Model
  """

  use Snitch.Data.Model
  alias Snitch.Data.Schema.ShippingCategory

  @doc """
  Updates the shipping_category with supplied `params`. `params` can include
  `shipping_rules`.

  To update or insert `shipping_rules` these should be preloaded in the
  supplied `shipping_category` struct.

  ## Caution!

  The `shipping_rules` are "casted" with the shipping_category and if `params`
  does not include a `shipping_rules`, then **all previous shipping_rules will
  be deleted!**

  ## See also
  `Ecto.Changeset.cast_assoc/3`
  """
  @spec update(map, ShippingCategory.t()) ::
          {:ok, ShippingCategory.t()}
          | {:error, Ecto.Changeset.t()}
  def update(params, shipping_category) do
    QH.update(ShippingCategory, params, shipping_category, Repo)
  end

  @doc """
  Returns a `shipping_category` with `shipping_rules`.

  Takes as input `id` of the `shipping_category` to be retrieved.
  """
  @spec get_with_rules(non_neg_integer) :: {:ok, ShippingCategory.t()} | {:error, atom}
  def get_with_rules(id) do
    with {:ok, shipping_category} <- QH.get(ShippingCategory, id, Repo) do
      shipping_category =
        shipping_category |> Repo.preload(shipping_rules: :shipping_rule_identifier)

      {:ok, shipping_category}
    end
  end
end
