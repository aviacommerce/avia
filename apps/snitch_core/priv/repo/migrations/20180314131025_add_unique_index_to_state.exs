defmodule Snitch.Repo.Migrations.AddUniqueIndexToState do
  use Ecto.Migration

  def change do
    create unique_index(:snitch_states, [:abbr, :country_id], 
    message: "(:country_id, :abbr) is already taken")
  end
end
