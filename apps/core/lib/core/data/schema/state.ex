defmodule Snitch.Core.Data.Schema.State do
  @moduledoc """
  Models a State
  """

  use Snitch.Core.Data.Schema

  schema "snitch_states" do
    field(:name, :string)
    field(:abbr, :string)
    belongs_to(:country, Country, foreign_key: :country_id)

    timestamps()
  end

  def changeset(%State{} = state, attrs \\ %{}) do
    state
    |> cast(attrs, [:abbr, :name, :country_id])
    |> validate_required([:abbr, :name, :country_id])
    |> foreign_key_constraint(:country_id)
  end
end
