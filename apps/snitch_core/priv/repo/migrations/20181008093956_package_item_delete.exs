defmodule Snitch.Repo.Migrations.PackageItemDelete do
  use Ecto.Migration

  def change do
    drop constraint("snitch_package_items", "snitch_package_items_line_item_id_fkey")
    alter table("snitch_package_items") do
      modify :line_item_id, references("snitch_line_items", on_delete: :delete_all)
    end
  end
end
