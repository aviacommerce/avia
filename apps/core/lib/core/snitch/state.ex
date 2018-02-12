defmodule Core.Snitch.State do
  use Ecto.Schema
  import Ecto.Changeset
  alias Core.Snitch.Country
  alias __MODULE__, as: State

  schema "snitch_states" do
    field(:name, :string)
    field(:abbr, :string)
    belongs_to(:snitch_countries, Country, foreign_key: :country_id)

    timestamps()
  end

  def changeset(%State{} = state, attrs \\ %{}) do
    state
    |> cast(attrs, [:abbr, :name, :country_id])
    |> validate_required([:abbr, :name, :country_id])
    |> foreign_key_constraint(:country_id)
  end
end
