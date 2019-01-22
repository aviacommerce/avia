defmodule Snitch.Data.Schema.EAV.Decimal do
  @moduledoc """

  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.EAV.Attribute

  schema "snitch_eav_type_decimal" do
    field(:value, :decimal)

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
