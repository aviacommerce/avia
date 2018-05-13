defmodule Snitch.Data.Schema.Taxonomy do
  @moduledoc """

  """
  use Snitch.Data.Schema
  alias Snitch.Data.Schema.Taxon

  @type t :: %__MODULE__{}

  schema "snitch_taxonomies" do
    field(:name, :string)

    belongs_to(:root, Taxon)
    timestamps()
  end

  @cast_fields [:name, :root_id]

  def changeset(taxonomy, params \\ %{}) do
    taxonomy
    |> cast(params, @cast_fields)
  end
end
