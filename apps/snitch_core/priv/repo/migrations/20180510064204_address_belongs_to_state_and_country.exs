defmodule Snitch.Repo.Migrations.AddressBelongsToStateAndCountry do
  use Ecto.Migration

  def change do
    alter table("snitch_addresses") do
      add :state_id, references("snitch_states", on_delete: :nothing)
      add :country_id, references("snitch_countries", on_delete: :nothing), null: false
    end
  end
end
