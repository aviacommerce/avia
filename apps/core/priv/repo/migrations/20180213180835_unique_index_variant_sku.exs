defmodule Core.Repo.Migrations.UniqueIndexVariantSku do
  use Ecto.Migration

  def change do
    create unique_index(:snitch_variants, [:sku])
  end
end
