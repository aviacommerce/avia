defmodule Snitch.Data.Schema.EAV.Boolean do
  @moduledoc """
  Models the boolean type for EAV structure.
  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.EAV.Attribute

  schema "snitch_eav_type_boolean" do
    field(:value, :boolean)

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
