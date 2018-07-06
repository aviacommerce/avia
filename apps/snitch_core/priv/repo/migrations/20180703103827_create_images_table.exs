defmodule Snitch.Repo.Migrations.CreateImagesTable do
  use Ecto.Migration

  def change do

    create table :snitch_images do
      add :url, :string
      add :variant_id, references("snitch_variants") 
    end

  end
end
