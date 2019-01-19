defmodule Snitch.Data.Schema.Entity do
  @moduledoc """

  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.Attribute

  schema "snitch_entities" do
    field(:name, :string)
    field(:identifier, EntityIdentifier)
    field(:description, :string)

    has_many(:attributes, Attribute)

    timestamps()
  end
end
