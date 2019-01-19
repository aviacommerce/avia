defmodule Snitch.Data.Schema.EAV.DateTime do
  @moduledoc """

  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.Attribute

  schema "snitch_eav_type_datetime" do
    field(:value, :utc_datetime)

    belongs_to(:attribute, Attribute, on_replace: :delete)

    timestamps()
  end
end
