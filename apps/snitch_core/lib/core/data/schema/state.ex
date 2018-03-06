defmodule Snitch.Data.Schema.State do
  @moduledoc """
  Models a State
  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.Country
  alias __MODULE__

  schema "snitch_states" do
    field(:name, :string)
    field(:abbr, :string)
    belongs_to(:country, Country)

    timestamps()
  end

  def changeset(%State{} = state, attrs \\ %{}) do
    state
    |> cast(attrs, [:abbr, :name, :country_id])
    |> validate_required([:abbr, :name, :country_id])
    |> foreign_key_constraint(:country_id)
  end
end
