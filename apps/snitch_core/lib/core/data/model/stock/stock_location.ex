defmodule Snitch.Data.Model.StockLocation do
  @moduledoc """
    This module provides methods and utils for
    Stock Locations by interacting with DB.
  """
  use Snitch.Data.Model
  alias Snitch.Data.Schema.StockLocation, as: StockLocationSchema

  @spec create(charlist, charlist, non_neg_integer, non_neg_integer) ::
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
    with opetion `only_active: true` we can fetch active locations
  """
  @spec get_all(list) :: list(StockLocationSchema.t())
  def get_all(opts \\ [is_active?: false])

  def get_all(is_active: true),
    do: Repo.all(from(sl in StockLocationSchema, where: sl.active == true))

  def get_all(_), do: StockLocationSchema |> Repo.all()
end
