defmodule Snitch.Data.Schema.Attribute do
  @moduledoc """

  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.Entity

  schema "snitch_attributes" do
    field(:name, :string)
    field(:description, :string)

    belongs_to(:entity, Entity, on_replace: :delete)
    timestamps()
  end
end
