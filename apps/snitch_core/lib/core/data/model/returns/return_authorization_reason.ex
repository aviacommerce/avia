defmodule Snitch.Data.Model.ReturnAuthorizationReason do
  @moduledoc """
  Provides methods and utils for return authorization reason schema.
  This will be associated with return authorization later.
  """

  use Snitch.Data.Model
  alias Snitch.Data.Schema.ReturnAuthorizationReason, as: RARSchema

  @spec create(map) :: {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def create(query_fields) do
    QH.create(RARSchema, query_fields, Repo)
  end

  @spec update(non_neg_integer | map, RARSchema.t() | nil) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def update(query_fields, instance \\ nil) do
    QH.update(RARSchema, query_fields, instance, Repo)
  end

  @spec delete(non_neg_integer | StockLocationSchema.t()) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def delete(id_or_instance) do
    QH.delete(RARSchema, id_or_instance, Repo)
  end

  @spec get(integer() | map) :: RARSchema.t()
  def get(query_fields) do
    QH.get(RARSchema, query_fields, Repo)
  end

  @spec get_all :: list(RARSchema.t())
  def get_all, do: Repo.all(RARSchema)

  @spec formatted_list() :: [{String.t(), non_neg_integer}]
  def formatted_list, do: Repo.all(from(s in RARSchema, where: s.active == true, select: {s.name, s.id}))
end
