defmodule Snitch.Data.Schema.EAV.String do
  @moduledoc """

  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.Attribute

  schema "snitch_eav_type_string" do
    field(:value, :string)

    belongs_to(:attribute, Attribute, on_replace: :delete)

    timestamps()
  end
end
