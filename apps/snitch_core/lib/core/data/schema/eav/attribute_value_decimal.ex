defmodule Snitch.Data.Schema.EAV.Decimal do
  @moduledoc """

  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.Attribute

  schema "snitch_eav_type_decimal" do
    field(:value, :decimal)

    belongs_to(:attribute, Attribute, on_replace: :delete)

    timestamps()
  end
end
