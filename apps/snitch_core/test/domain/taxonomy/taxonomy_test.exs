defmodule Snitch.Core.Domain.TaxonomyTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Schema.Taxon
  alias Snitch.Domain.Taxonomy

  # Will create a better code for this to create taxonomy from list or map
  # Creates following taxonomy
  #   ├── Home & Living
  #   │   └── Kitchen & Table
  #   │   └── Table Cover
  #   ├── Mats & Napkin
  #   ├── Home decor

  defp create_taxonomy do
    taxonomy = insert(:taxonomy, name: "Home & Living")

    home_living =
      insert(:taxon,
        name: "Home & Living",
        slug: Taxon.generate_slug("Home & Living"),
        lft: 0,
        rgt: 11,
        taxonomy: taxonomy
      )

    taxonomy
    |> Ecto.Changeset.change(root_id: home_living.id)
    |> Repo.update()

    flooring =
      insert(
        :taxon,
        name: "Flooring",
        slug: Taxon.generate_slug("Flooring"),
        lft: 1,
        rgt: 2,
        parent_id: home_living.id,
        taxonomy: taxonomy
      )

    kitchen_table =
      insert(
        :taxon,
        name: "Kitchen & Tables",
        slug: Taxon.generate_slug("Kitchen & Tables"),
        lft: 3,
        rgt: 8,
        parent_id: home_living.id,
        taxonomy: taxonomy
      )

    home_decor =
      insert(
        :taxon,
        name: "Home Decor",
        slug: Taxon.generate_slug("Home Decor"),
        lft: 9,
        rgt: 10,
        parent_id: home_living.id,
        taxonomy: taxonomy
      )

    table_cover =
      insert(
        :taxon,
        name: "Table Covers",
        slug: Taxon.generate_slug("Table Covers"),
        lft: 4,
        rgt: 5,
        parent_id: kitchen_table.id,
        taxonomy: taxonomy
      )

    mat_napkins =
      insert(
        :taxon,
        name: "Mat & Napkins",
        slug: Taxon.generate_slug("Mat & Napkins"),
        lft: 6,
        rgt: 7,
        parent_id: kitchen_table.id,
        taxonomy: taxonomy
      )

    {home_living,
     [
       {flooring, []},
       {kitchen_table,
        [
          {table_cover, []},
          {mat_napkins, []}
        ]},
       {home_decor, []}
     ]}
  end

  describe "add_taxon/2" do
    test "add taxon" do
      {_, [{flooring, _} | _]} = create_taxonomy()

      carpet = %Taxon{name: "Carpet"}
      {:ok, taxon} = Taxonomy.add_taxon(flooring, carpet, :child)

      assert taxon.name == "Carpet"
      assert taxon.taxonomy_id == flooring.taxonomy_id
      assert taxon.parent_id == flooring.id

      taxonomy = dump_taxonomy(flooring)

      assert {%{name: "Home & Living"},
              [
                {%{name: "Flooring"},
                 [
                   {%{name: "Carpet"}, []}
                 ]},
                {%{name: "Kitchen & Tables"},
                 [
                   {%{name: "Table Covers"}, []},
                   {%{name: "Mat & Napkins"}, []}
                 ]},
                {%{name: "Home Decor"}, []}
              ]} = taxonomy

      lamp_light = %Taxon{name: "Lamp and Lights"}
      {:ok, taxon} = Taxonomy.add_taxon(flooring, lamp_light, :left)

      taxonomy = dump_taxonomy(flooring)

      assert taxon.lft == 1
      assert taxon.rgt == 2
      assert taxon.parent_id == flooring.parent_id

      assert {%{name: "Home & Living"},
              [
                {%{name: "Lamp and Lights"}, []},
                {%{name: "Flooring"},
                 [
                   {%{name: "Carpet"}, []}
                 ]},
                {%{name: "Kitchen & Tables"},
                 [
                   {%{name: "Table Covers"}, []},
                   {%{name: "Mat & Napkins"}, []}
                 ]},
                {%{name: "Home Decor"}, []}
              ]} = taxonomy

      storage = %Taxon{name: "Storage"}
      {:ok, taxon} = Taxonomy.add_taxon(flooring, storage, :right)

      taxonomy = dump_taxonomy(flooring)

      assert taxon.lft == 7
      assert taxon.rgt == 8
      assert taxon.parent_id == flooring.parent_id

      assert {%{name: "Home & Living"},
              [
                {%{name: "Lamp and Lights"}, []},
                {%{name: "Flooring"},
                 [
                   {%{name: "Carpet"}, []}
                 ]},
                {%{name: "Storage"}, []},
                {%{name: "Kitchen & Tables"},
                 [
                   {%{name: "Table Covers"}, []},
                   {%{name: "Mat & Napkins"}, []}
                 ]},
                {%{name: "Home Decor"}, []}
              ]} = taxonomy

      home_decoration = %Taxon{name: "Home Decoration"}
      {:ok, taxon} = Taxonomy.add_taxon(flooring, home_decoration, :parent)

      taxonomy = dump_taxonomy(flooring)

      assert taxon.lft == 3
      assert taxon.rgt == 8

      assert {%{name: "Home & Living"},
              [
                {%{name: "Lamp and Lights"}, []},
                {%{name: "Home Decoration"},
                 [
                   {%{name: "Flooring"},
                    [
                      {%{name: "Carpet"}, []}
                    ]}
                 ]},
                {%{name: "Storage"}, []},
                {%{name: "Kitchen & Tables"},
                 [
                   {%{name: "Table Covers"}, []},
                   {%{name: "Mat & Napkins"}, []}
                 ]},
                {%{name: "Home Decor"}, []}
              ]} = taxonomy
    end

    test "add taxon with same name fails" do
      {:ok, %{root_taxon: root}} = Taxonomy.create_taxonomy("Categories")
      root = root |> Repo.preload(:taxonomy)

      taxon = %Taxon{name: "Shirt"}

      {:ok, _} = Taxonomy.add_taxon(root, taxon, :child)

      {:error, changeset} = Taxonomy.add_taxon(root, taxon, :child)
      assert changeset.errors[:slug] == {"category with this name alreay exist", []}
    end
  end

  describe "add_root/1" do
    test "create root for empty taxonomy" do
      taxonomy = insert(:taxonomy, name: "Home & Living")
      taxon = %Taxon{name: "root", taxonomy_id: taxonomy.id}

      root = Taxonomy.add_root(taxon)

      assert root.name == taxon.name
      assert root.taxonomy_id == taxonomy.id
    end
  end

  describe "dump_taxonomy/1" do
    test "dump valid taxonomy" do
      {_, [{target, _} | _]} = create_taxonomy()

      dump = Taxonomy.dump_taxonomy(target)

      assert match?(
               {%{name: "Home & Living"},
                [
                  {%{name: "Flooring"}, []},
                  {%{name: "Kitchen & Tables"},
                   [
                     {%{name: "Table Covers"}, []},
                     {%{name: "Mat & Napkins"}, []}
                   ]},
                  {%{name: "Home Decor"}, []}
                ]},
               dump
             )
    end

    test "dump invalid taxonomy" do
      dump = Taxonomy.dump_taxonomy(-1)
      assert [] == dump
    end
  end

  describe "is_root?/1" do
    test "test all cases" do
      {root_taxon, [{random_taxon, _} | _]} = create_taxonomy()
      root_taxon = Repo.preload(root_taxon, :taxonomy, force: true)

      assert Taxonomy.is_root?(root_taxon)
      refute Taxonomy.is_root?(random_taxon)

      taxon_without_taxonomy = insert(:taxon, name: "Shirts", slug: Taxon.generate_slug("Shirts"))

      assert_raise RuntimeError, "No taxonomy is associated with taxon", fn ->
        Taxonomy.is_root?(taxon_without_taxonomy)
      end
    end
  end

  defp dump_taxonomy(taxon) do
    taxon
    |> Taxonomy.get_root()
    |> Taxonomy.dump_taxonomy()
  end
end
