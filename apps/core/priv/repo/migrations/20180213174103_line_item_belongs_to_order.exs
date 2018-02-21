defmodule Core.Repo.Migrations.LineItemBelongsToOrder do
  use Ecto.Migration

  def change do
    alter table(:snitch_line_items) do
      add :order_id, references("snitch_orders", on_delete: :delete_all), null: false
    end
  end
end
