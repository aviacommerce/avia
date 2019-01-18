defmodule Snitch.Data.Model.ShippingMethod do
  @moduledoc """
  ShippingMethod API
  """
  use Snitch.Data.Model

  import Ecto.Query

  alias Snitch.Data.Schema.ShippingMethod, as: SM
  alias Snitch.Data.Schema.ShippingCategory, as: SC
  alias Snitch.Data.Schema.Zone

  @doc """
  Creates a ShippingMethod with given Zones.

  * The `zone_structs` must be `Snitch.Data.Schema.Zone.t` structs.
  * The `category_structs` must be `Snitch.Data.Schema.ShippingCategory.t`
    structs.
  """
  @spec create(map, [Zone.t()], [SC.t()]) :: {:ok, SM.t()} | {:error, Ecto.Changeset.t()}
  def create(params, zone_structs, category_structs) do
    cs = SM.create_changeset(%SM{}, params, zone_structs, category_structs)
    Repo.insert(cs)
  end

  @doc """
  Updates a ShippingMethod.

  The `zone_structs` must be `Snitch.Data.Schema.Zone.t` structs. These `zones`
  are set as the zones in this `shipping_method` and effectively replace the
  previous ones.

  Similarily for `category_structs`, these must be
  `Snitch.Data.Schema.ShippingCategory.t` structs.

  ## Updating the zones, shipping-categories
  ```
  new_params = %{name: "hyperloop"}
  new_zones = Repo.all(from z in Schema.Zone, where: like(z.name, "spacex%"))

  new_categories = Repo.all(
    from sc in Schema.ShippingCategory,
    where: like(sc.name, "heavy%")
  )

  {:ok, sm} =
     Model.ShippingMethod.update(
       shipping_method,
       new_params,
       new_zones,
       new_categories
     )
  ```

  ## Updating only params (not zones or shipping-categories)
  ```
  new_params = %{name: "hyperloop"}
  sm_preloaded = Repo.preload(shipping_method, [:zones, :shipping_categories])

  {:ok, sm} =
    Model.ShippingMethod.update(
      sm_preloaded,
      new_params,
      sm_preloaded.zones,
      sm_preloaded.shipping_categories
    )
  ```
  """
  @spec update(SM.t(), map, [Zone.t()], [SC.t()]) :: {:ok, SM.t()} | {:error, Ecto.Changeset.t()}
  def update(shipping_method, params, zone_structs, category_structs) do
    cs = SM.update_changeset(shipping_method, params, zone_structs, category_structs)
    Repo.update(cs)
  end

  @spec delete(non_neg_integer | SM.t()) :: {:ok, SM.t()} | {:error, Ecto.Changeset.t()}
  def delete(id_or_instance) do
    QH.delete(SM, id_or_instance, Repo)
  end

  @spec get(map | non_neg_integer) :: {:ok, SM.t()} | {:error, atom}
  def get(query_fields_or_primary_key) do
    QH.get(SM, query_fields_or_primary_key, Repo)
  end

  @spec get_all :: [SM.t()]
  def get_all, do: Repo.all(SM)

  @spec for_package_query([Zone.t()], SC.t()) :: Ecto.Query.t()
  def for_package_query(zones, %SC{} = shipping_category)
      when is_list(zones) do
    zone_ids = Enum.map(zones, fn %{id: id} -> id end)

    from(
      sm_z in "snitch_shipping_methods_zones",
      join: sm_c in "snitch_shipping_methods_categories",
      on: sm_c.shipping_method_id == sm_z.shipping_method_id,
      join: sm in SM,
      on: sm_z.shipping_method_id == sm.id,
      where: sm_z.zone_id in ^zone_ids,
      where: sm_c.shipping_category_id == ^shipping_category.id,
      distinct: sm.id,
      select: sm
    )
  end
end
