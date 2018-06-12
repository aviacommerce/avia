defmodule Snitch.ShipmentCase do
  @moduledoc """
  Test helpers to insert shipping related schemas.
  """

  alias Snitch.Data.Model.ShippingMethod
  alias Snitch.Data.Schema.ShippingCategory
  alias Snitch.Repo

  @shipping_category %{
    name: nil,
    inserted_at: Ecto.DateTime.utc(),
    updated_at: Ecto.DateTime.utc()
  }

  @doc """
  Creates `ShippingCategory`s according to the manifest.

  ## Sample manifests
  ```
  category_manifest = ~w(international domestic local)
  ```
  """
  def shipping_categories_with_manifest(manifest) do
    categories = Enum.map(manifest, fn name -> %{@shipping_category | name: name} end)

    {_, categories} = Repo.insert_all(ShippingCategory, categories, returning: true)
    categories
  end

  @doc """
  Creates `ShippingMethod`s according to the manifest.

  ## Sample manifests
  ```
  methods_manifest = %{
    "priority_mail" => {zones, shipping_category},
  }
  ```
  """
  def shipping_methods_with_manifest(manifest) do
    manifest
    |> Stream.map(fn {name, {zones, categories}} ->
      ShippingMethod.create(%{name: name, slug: name}, zones, categories)
    end)
    |> Enum.map(fn {:ok, sm} -> sm end)
  end
end
