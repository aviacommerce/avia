defmodule Snitch.Data.Schema.EAV.Entity do
  @moduledoc """
  Models the entity in the Entity Attribute Value modelling.

  The EAV modelling is being used in Snitch for a specific purpose
  of storing configuration data which can be extended dynamically
  as per demand.

  Data can be related to app configuration, taxes etc. The EAV strucutre
  should be used specifically for storing configuration related data.
  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.EAV.Attribute

  @type t :: %__MODULE__{}

  schema "snitch_entities" do
    field(:name, :string)
    field(:identifier, EntityIdentifier)
    field(:description, :string)

    has_many(:attributes, Attribute)

    timestamps()
  end

  @create_params ~w(name description identifier)a
  @required ~w(name identifier)a

  def changeset(%__MODULE__{} = entity, params) do
    entity
    |> cast(params, @create_params)
    |> validate_required(@required)
    |> cast_assoc(:attributes, with: &Attribute.create_changeset/2)
  end
end
