defmodule Snitch.Data.Model.Card do
  use Snitch.Data.Model
  alias Snitch.Data.Schema.Card, as: CardSchema

  @spec create(map) :: {:ok, CardSchema.t()} | {:error, Ecto.Changeset.t()}
  def create(query_fields) do
    QH.create(CardSchema, query_fields, Repo)
  end

  @spec update(map) :: {:ok, CardSchema.t()} | {:error, Ecto.Changeset.t()}
  def update(query_fields) do
    QH.update(CardSchema, query_fields, Repo)
  end
end
