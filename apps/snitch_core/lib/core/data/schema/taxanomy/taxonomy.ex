defmodule Snitch.Data.Schema.Taxonomy do
  @moduledoc false
  use Snitch.Data.Schema

  alias Snitch.Data.Schema.Taxon

  @type t :: %__MODULE__{}

  schema "snitch_taxonomies" do
    field(:name, :string)
    field(:taxons, :any, virtual: true)

    belongs_to(:root, Taxon)
    timestamps()
  end

  @cast_fields [:name, :root_id]

  def changeset(taxonomy, params \\ %{}) do
    cast(taxonomy, params, @cast_fields)
  end
end
