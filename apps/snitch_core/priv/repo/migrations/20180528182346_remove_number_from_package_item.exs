defmodule Snitch.Repo.Migrations.RemoveNumberFromPackageItem do
  use Ecto.Migration

  def change do
    drop unique_index("snitch_package_items", [:number])
    alter table("snitch_package_items") do
      remove :number
    end
  end
end
