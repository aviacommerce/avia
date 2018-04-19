defmodule Snitch.Data.Model.ShippingMethod do
  @moduledoc """
  ShippingMethod API
  """
  use Snitch.Data.Model
  alias Snitch.Data.Schema.ShippingMethod, as: SMSchema
  alias Snitch.Data.Schema.Zone

  @doc """
  Creates a ShippingMethod with given Zones.

  The `zones` must be `Snitch.Data.Schema.Zone.t` structs.
  """
  @spec create(map, [Zone.t()]) :: {:ok, SMSchema.t()} | {:error, Ecto.Changeset.t()}
  def create(params, zone_structs) do
    cs = SMSchema.create_changeset(%SMSchema{}, params, zone_structs)
    Repo.insert(cs)
  end

  @doc """
  Updates a ShippingMethod.

  The `zones` must be `Snitch.Data.Schema.Zone.t` structs. These `zones` are set
  as the zones in this `shipping_method` and effectively replace the previous
  ones.

  ## Updating the zones
  ```
  new_params = %{name: "hyperloop"}
  new_zones = Repo.all(from z in Schema.Zone, where: like(z.name, "spacex%"))
  {:ok, sm} = Model.ShippingMethod.update(shipping_method, new_params, new_zones)
  ```

  ## Updating only params (not zones)
  ```
  new_params = %{name: "hyperloop"}
  sm_preloaded = Repo.preload(shipping_method, :zones)
  {:ok, sm} = Model.ShippingMethod.update(sm_preloaded, new_params, sm_preloaded.zones)
  ```
  """
  @spec update(SMSchema.t(), map, [Zone.t()]) ::
          {:ok, SMSchema.t()} | {:error, Ecto.Changeset.t()}
  def update(shipping_method, params, zone_structs) do
    cs = SMSchema.update_changeset(shipping_method, params, zone_structs)
    Repo.update(cs)
  end

  @spec delete(non_neg_integer | SMSchema.t()) ::
          {:ok, SMSchema.t()} | {:error, Ecto.Changeset.t()}
  def delete(id_or_instance) do
    QH.delete(SMSchema, id_or_instance, Repo)
  end

  @spec get(map | non_neg_integer) :: SMSchema.t() | nil
  def get(query_fields_or_primary_key) do
    QH.get(SMSchema, query_fields_or_primary_key, Repo)
  end

  @spec get_all :: [SMSchema.t()]
  def get_all, do: Repo.all(SMSchema)
end
