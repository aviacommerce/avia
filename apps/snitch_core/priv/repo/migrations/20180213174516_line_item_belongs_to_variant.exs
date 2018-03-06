defmodule Core.Repo.Migrations.LineItemBelongsToVariant do
  use Ecto.Migration

  def change do
    alter table(:snitch_line_items) do
      add :variant_id, references("snitch_variants"), null: false
    end
  end
end
