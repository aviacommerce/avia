defmodule Snitch.Data.Schema.StoreProps do
  @moduledoc false

  use Snitch.Data.Schema

  @type t :: %__MODULE__{}

  schema "snitch_store_props" do
    field(:key, :string)
    field(:value, :string)
    timestamps()
  end

  @required_fields ~w(key value)a

  def changeset(%__MODULE__{} = store_props, params) do
    store_props
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
  end
end
