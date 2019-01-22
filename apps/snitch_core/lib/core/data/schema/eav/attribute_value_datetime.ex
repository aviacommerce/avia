defmodule Snitch.Data.Schema.EAV.DateTime do
  @moduledoc """
  Models datetime type for the EAV structure.
  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.EAV.Attribute

  schema "snitch_eav_type_datetime" do
    field(:value, :utc_datetime)

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
