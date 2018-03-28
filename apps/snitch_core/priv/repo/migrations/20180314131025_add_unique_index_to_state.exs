defmodule Snitch.Repo.Migrations.AddUniqueIndexToState do
  use Ecto.Migration

  def change do
    create(
      unique_index(:snitch_states, [:abbr, :country_id], name: :snitch_state_abbr_and_country_id)
    )
  end
end
