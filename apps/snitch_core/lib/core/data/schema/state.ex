defmodule Snitch.Data.Schema.State do
  @moduledoc """
  Models a State
  """
  use Snitch.Data.Schema
  alias Snitch.Data.Schema.Country

  @type t :: %__MODULE__{}

  schema "snitch_states" do
    field(:name, :string)
    field(:code, :string)
    belongs_to(:country, Country)

    timestamps()
  end

  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = state, params) do
    state
    |> cast(params, [:code, :name, :country_id])
    |> validate_required([:code, :name, :country_id])
    |> foreign_key_constraint(:country_id)
    |> unique_constraint(:code)
  end
end
