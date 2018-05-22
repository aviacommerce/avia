defmodule Snitch.Data.Model.StockLocation do
  @moduledoc """
  This module provides methods and utils for
  Stock Locations by interacting with DB.
  """
  use Snitch.Data.Model
  alias Snitch.Data.Schema.StockLocation, as: StockLocationSchema

  @spec create(String.t(), String.t(), non_neg_integer, non_neg_integer) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def create(name, address, state_id, country_id) do
    QH.create(
      StockLocationSchema,
      %{
        name: name,
        address_line_1: address,
        state_id: state_id,
        country_id: country_id
      },
      Repo
    )
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

  @spec get(integer() | map) :: StockLocationSchema.t()
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

  """
  @spec get_all_with_items_for_variants([non_neg_integer]) :: [StockLocationSchema.t()]
  def get_all_with_items_for_variants(variant_ids) when is_list(variant_ids) do
    Repo.all(
      from(
        sl in active_locations(),
        join: si in assoc(sl, :stock_items),
        join: v in assoc(si, :variant),
        where: v.id in ^variant_ids,
        preload: [stock_items: {si, variant: v}]
      )
    )
  end

  ##############################################################################
  #                                   QUERIES                                  #
  ##############################################################################

  defp active_locations do
    from(sl in StockLocationSchema, where: sl.active == true)
  end
end
