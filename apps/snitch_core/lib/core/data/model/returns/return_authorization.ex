defmodule Snitch.Data.Model.ReturnAuthorization do
  @moduledoc """
  Provides methods and utils for return authorization reason schema.
  This will be associated with return authorization later.
  """

  use Snitch.Data.Model
  alias Snitch.Data.Schema.ReturnAuthorization, as: RASchema

  @spec create(map) :: {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def create(query_fields) do
    QH.create(RASchema, query_fields, Repo)
  end

  @spec update(non_neg_integer | map, RASchema.t() | nil) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def update(query_fields, instance \\ nil) do
    QH.update(RASchema, query_fields, instance, Repo)
  end

  @spec delete(non_neg_integer | StockLocationSchema.t()) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def delete(id_or_instance) do
    QH.delete(RASchema, id_or_instance, Repo)
  end

  @spec get(integer() | map) :: RASchema.t()
  def get(query_fields) do
    QH.get(RASchema, query_fields, Repo)
  end

  @spec get_all :: list(RASchema.t())
  def get_all, do: Repo.all(RASchema)
end
