defmodule Snitch.Data.Schema.State do
  @moduledoc """
  Models a State
  """
  use Snitch.Data.Schema
  alias Snitch.Data.Schema.Country

  @type t :: %__MODULE__{}

  schema "snitch_states" do
    field(:name, :string)
    field(:abbr, :string)
    belongs_to(:country, Country)

    timestamps()
  end

  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = state, params) do
    state
    |> cast(params, [:abbr, :name, :country_id])
    |> validate_required([:abbr, :name, :country_id])
    |> foreign_key_constraint(:country_id)
    |> unique_constraint(
      :abbr,
      name: :snitch_state_abbr_and_country_id,
      message: "(:country_id, :abbr) has already been taken"
    )
  end
end
