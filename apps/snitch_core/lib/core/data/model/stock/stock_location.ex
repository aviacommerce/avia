defmodule Snitch.Data.Model.StockLocation do
  @moduledoc """
    This module provides methods or utils for
    Stock Locations by interacting with DB.
  """
  use Snitch.Data.Model
  alias Snitch.Data.Schema.StockLocation, as: StockLocationSchema

  @spec create(charlist, charlist, non_neg_integer, non_neg_integer) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def create(address, name, state_id, country_id) do
    QH.create(
      StockLocationSchema,
      %{
        address_line_1: address,
        name: name,
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
  Fetches all the stock locations present in the DB
  """
  @spec get_all :: list(StockLocationSchema.t())
  def get_all, do: StockLocationSchema |> Repo.all()

  @doc """
  Fetches all the `active` stock locations present in the DB
  """
  @spec stock_locations :: list(StockLocationSchema.t())
  def stock_locations do
    Repo.all(from(sl in StockLocationSchema, where: sl.active == true))
  end
end
