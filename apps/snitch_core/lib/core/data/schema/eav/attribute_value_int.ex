defmodule Snitch.Data.Schema.EAV.Integer do
  @moduledoc """

  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.Attribute

  schema "snitch_eav_type_integer" do
    field(:value, :integer)

    belongs_to(:attribute, Attribute, on_replace: :delete)

    timestamps()
  end
end
