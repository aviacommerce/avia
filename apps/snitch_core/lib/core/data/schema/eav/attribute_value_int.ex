defmodule Snitch.Data.Schema.EAV.Integer do
  @moduledoc """
  Models the integer type for EAV structure.
  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.EAV.Attribute

  schema "snitch_eav_type_integer" do
    field(:value, :integer)

    belongs_to(:attribute, Attribute, on_replace: :delete)

    timestamps()
  end

  @required ~w(attribute_id value)a

  def changeset(%__MODULE__{} = data, params) do
    data
    |> cast(params, @required)
    |> validate_required(@required)
  end
end
