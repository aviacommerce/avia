defmodule Snitch.Repo.Migrations.RenameAbbrToCodeInStates do
  use Ecto.Migration

  def change do
    drop index("snitch_states", [:abbr, :country_id], name: :snitch_state_abbr_and_country_id)

    alter table(:snitch_states) do
      remove :abbr
      add :code, :string, null: false
    end

    create unique_index(:snitch_states, [:code])
  end
end
