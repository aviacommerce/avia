defmodule Snitch.Data.Model.StockLocation do
  @moduledoc """
  This module provides methods and utils for
  Stock Locations by interacting with DB.
  """
  use Snitch.Data.Model
  alias Snitch.Data.Schema.StockLocation, as: StockLocationSchema

  @spec create(map) :: {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def create(query_fields) do
    QH.create(StockLocationSchema, query_fields, Repo)
  end

  @spec update(non_neg_integer | map, StockLocationSchema.t() | nil) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def update(query_fields, instance \\ nil) do
    QH.update(StockLocationSchema, query_fields, instance, Repo)
  end

  @spec delete(non_neg_integer | StockLocationSchema.t()) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def delete(id_or_instance) do
    QH.delete(StockLocationSchema, id_or_instance, Repo)
  end

  @spec get(integer() | map) :: {:ok, StockLocationSchema.t()} | {:error, atom}
  def get(query_fields) do
    QH.get(StockLocationSchema, query_fields, Repo)
  end

  @doc """
  Fetches stock locations present in the DB.
  """
  @spec get_all :: list(StockLocationSchema.t())
  def get_all, do: Repo.all(StockLocationSchema)

  @doc """
  Fetch all `active` stock locations
  """
  @spec active :: list(StockLocationSchema.t())
  def active, do: Repo.all(active_locations())

  @doc """
  Fetches all stock locations with stock items for variants among `variant_ids`.

  The purpose of this function is to preload all the stock information of the
  variants requested in an order.
  Returns:
  * `StockLocation` structs, with
    - all (relevant) `StockItem` structs, with
      + `Variant` struct and its `ShippingCategory`
  """
  @spec get_all_with_items_for_variants([non_neg_integer]) :: [StockLocationSchema.t()]
  def get_all_with_items_for_variants([]), do: []

  def get_all_with_items_for_variants(variant_ids) when is_list(variant_ids) do
    # It is unclear if there will be any gains by splitting this into a compound
    # query:
    # subquery = from v in Variant, where v.id in ^variant_ids
    # query = from slin active_locations(), join: ..., join: subquery(), preload: ...
    Repo.all(
      from(
        sl in active_locations(),
        join: si in assoc(sl, :stock_items),
        join: v in assoc(si, :product),
        left_join: sc in assoc(v, :shipping_category),
        where: v.id in ^variant_ids,
        preload: [stock_items: {si, product: {v, shipping_category: sc}}]
      )
    )
  end

  ##############################################################################
  #                                   QUERIES                                  #
  ##############################################################################

  defp active_locations do
    from(sl in StockLocationSchema, where: sl.active == true)
  end

  def search(_params) do
    Repo.all(StockLocationSchema)
  end
end
