defmodule Snitch.Data.Schema.EAV.AttributeMetadata do
  @moduledoc """
  Stores metadata for an attribute.
  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.EAV.Attribute

  schema "snitch_attributes_metadata" do
    field(:data_type, AttributeDataType)
    field(:presentation, :string)
    field(:is_required, :boolean, default: false)
    field(:belongs_to_type, AttributeRelations)

    belongs_to(:attribute, Attribute, on_replace: :delete)

    timestamps()
  end

  @required ~w(data_type presentation attribute_id)a
  @permitted ~w(belongs_to_type)a ++ @required

  def changeset(%__MODULE__{} = metadata, params) do
    metadata
    |> cast(params, @permitted)
    |> validate_required(@required)
  end
end
