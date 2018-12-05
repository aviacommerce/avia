defmodule Snitch.Repo.Migrations.CreateZoneTables do
  use Ecto.Migration

  @zone_exclusivity_fn ~s"""
  create or replace function #{ prefix() || "public" }.zone_exclusivity(
    in supertype_id bigint,
    in subtype_discriminator varchar(1)
    )
  returns integer
  as $$
    select coalesce(
      (select 1
        from  #{ prefix() || "public" }.snitch_zones
        where id = supertype_id
        and   zone_type = subtype_discriminator),
      0)
  $$
  language sql;
  """

  def change do
    create table("snitch_zones") do
      add :name, :string, null: :false
      add :zone_type, :string, size: 1, null: false, comment: "discriminator"
      add :description, :text, null: false
      timestamps()
    end
    create constraint("snitch_zones", :valid_zone_type, check: "zone_type = any(array['S', 'C'])")

    create table("snitch_state_zone_members") do
      add :state_id, references("snitch_states", on_delete: :delete_all), null: false
      add :zone_id, references("snitch_zones", on_delete: :delete_all), null: false
      timestamps()
    end
    create unique_index("snitch_state_zone_members", [:zone_id, :state_id])

    create table("snitch_country_zone_members") do
      add :country_id, references("snitch_countries", on_delete: :delete_all), null: false
      add :zone_id, references("snitch_zones", on_delete: :delete_all), null: false
      timestamps()
    end
    create unique_index("snitch_country_zone_members", [:zone_id, :country_id])

    execute @zone_exclusivity_fn, "drop function #{ prefix() || "public" }.zone_exclusivity;"

    create constraint("snitch_state_zone_members", :state_zone_exclusivity, check: "#{ prefix() || "public" }.zone_exclusivity(zone_id, 'S') = 1")
    create constraint("snitch_country_zone_members", :country_zone_exclusivity, check: "#{ prefix() || "public" }.zone_exclusivity(zone_id, 'C') = 1")
  end
end
