defmodule Snitch.Data.Model.EAV do
  @moduledoc """
  Exposes functions related to handling EAV data.
  """

  use Snitch.Data.Model
  alias Snitch.Data.Schema.EAV.Entity

  def get_entity_attributes(entity_identifier) do
    Entity
    |> Repo.get_by(identifier: entity_identifier)
    |> preload([attributes: :metadata])
  end

  def create_entity(params) do
    changeset = Entity.changeset(%Entity{}, params)
    Repo.insert(changeset)
  end

  def create_attributes_with_metadata(entity_id, params) do
    entity = Entity |> Repo.get(entity_id) |> Repo.preload([attributes: :metadata])

    changeset = Entity.changeset(entity, params)
    Repo.update(changeset)
  end
end
