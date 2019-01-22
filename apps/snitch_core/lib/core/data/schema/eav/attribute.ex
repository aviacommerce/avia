defmodule Snitch.Data.Schema.EAV.Attribute do
  @moduledoc """
  Models the attributes for different entities.

  The `attributes` table contains all the fields that needs to be configured for
  an `entity`.
  ## See
  `Snitch.Data.Schema.Entity`

  This table allows new fields to be configured for an entity on the go.
  Each attribute represent a column had it been normal relational design.
  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.EAV.Entity
  alias Snitch.Data.Schema.EAV.AttributeMetadata

  @type t :: %__MODULE__{}

  schema "snitch_attributes" do
    field(:name, :string)
    field(:description, :string)

    belongs_to(:entity, Entity, on_replace: :delete)
    has_one(:metadata, AttributeMetadata, on_replace: :delete)

    timestamps()
  end

  @permitted ~w(name description entity_id)a
  @required ~w(name entity_id)a

  @doc """
  Returns a changeset for attributes.

  ### Note
  - The function uses `cast_assoc` for managing associations so
    rules specified by `cast_assoc` applies.
    __See__
    `Ecto.Changeset.cast_assoc(changeset, name, opts \\ [])`
  - The `:metadata` association needs to be preloaded before calling
    using the changeset for create or update action.
  """
  def changeset(%__MODULE__{} = attribute, params) do
    attribute
    |> cast(params, @permitted)
    |> validate_required(@required)
    |> cast_assoc(:metadata, with: &AttributeMetadata.changeset/2)
  end
end
