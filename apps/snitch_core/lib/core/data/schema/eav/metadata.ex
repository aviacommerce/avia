defmodule Snitch.Data.Schema.AttributeMetadata do
  use Snitch.Data.Schema
  alias Snitch.Data.Schema.Attribute

  schema "source" do
    field(:data_type, AttributeDataType)
    field(:presentation, :string)
    field(:is_required, :boolean)
    field(:belongs_to_entity, AttributeRelations)

    belongs_to(:attribute, Attribute, on_replace: :delete)

    timestamps()
  end
end
