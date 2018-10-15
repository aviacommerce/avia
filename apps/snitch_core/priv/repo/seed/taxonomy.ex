defmodule Snitch.Seed.Taxonomy do
  @moduledoc """
  Seeds basic taxonomy.
  """

  alias Snitch.Data.Schema.Taxonomy
  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias Snitch.Tools.Helper.Taxonomy, as: TaxonomyHelper

  @product_category {
    "Pets",
    [
      {"Dog",
       [
         {"Food",
          [
            {"Dry Food", []},
            {"Wet Food", []},
            {"Prescription Food", []},
            {"Freeze-Dried Food", []},
            {"Human-Grade", []},
            {"Dehydrated Food", []},
            {"Frozen Food", []},
            {"Food Toppings", []}
          ]},
         {"Treat",
          [
            {"Dental & Hard Chews", []},
            {"Soft & Chewy Treats", []},
            {"Biscuits & Crunchy Treats", []},
            {"Bully Sticks & Natural Chews ", []},
            {"Jerky Treats", []},
            {"Prescription Treats", []},
            {"Freeze-Dried Treats", []},
            {"Training Treats", []},
            {"Dehydrated Treats", []}
          ]},
         {"Toys", []},
         {"Healthcare", []},
         {"Dental Care", []},
         {"Vitamins & Suppliments", []},
         {"Cleaning & Potty", []},
         {"Creates, Pens and Gates", []},
         {"Beds & Mats", []},
         {"Carriers & Travel", []},
         {"Bowls and Feeders", []},
         {"Grooming", []},
         {"Flea & Trek", []},
         {"Leashes & Collars", []},
         {"Training & Behaviour", []},
         {"Clothing and Accessories", []},
         {"Gifts and Books", []},
         {"Technology", []}
       ]},
      {"Cat",
       [
         {"Food", []},
         {"Treat", []},
         {"Toys", []},
         {"Healthcare", []},
         {"Dental Care", []},
         {"Vitamins & Suppliments", []},
         {"Flea & Trick", []},
         {"Training & Cleaning", []},
         {"Crates, Pens and Gates", []},
         {"Beds & Mats", []},
         {"Trees, Condos & Scratchers", []},
         {"Carriers & Travel", []},
         {"Bowls & Feeders", []},
         {"Grooming", []},
         {"Leashes & Collars", []},
         {"Gifts and Books", []},
         {"Clothing and Accessories", []}
       ]},
      {"Fish",
       [
         {"Food & Treats", []},
         {"Aquariums & Starter Kits", []},
         {"Heathing and Lighting", []},
         {"Water Care", []},
         {"Decor & Accessories", []},
         {"Filters & Media", []},
         {"Cleaning & Maintainance", []},
         {"Health & Wellness", []},
         {"Gifts & Books", []},
         {"New Arrivals", []}
       ]},
      {"Bird",
       [
         {"Food", []},
         {"Treats", []},
         {"Cages and Accessories", []},
         {"Litter & Nesting", []},
         {"Perches & Toys", []},
         {"Grooming & Health", []},
         {"Gifts & Books", []},
         {"New Arrivals", []}
       ]},
      {"Small Pet",
       [
         {"Food & Treats", []},
         {"Habitats & Accessories", []},
         {"Bedding and Litter", []},
         {"Beds, Hideouts & Toys", []},
         {"Harnesses & Health", []},
         {"Grooming & Health", []},
         {"New Arrivals", []}
       ]},
      {"Reptile",
       [
         {"Food & Treats", []},
         {"Terrariums & Habitats", []},
         {"Habitat Accessories", []},
         {"Heating & Lighting", []},
         {"Cleaning & Maintainance", []},
         {"Substrate & Bedding", []},
         {"Health & Wellness", []},
         {"New Arrivals", []}
       ]},
      {"Horse",
       [
         {"Health & Wellness", []},
         {"Grooming", []},
         {"Tack & Stable Supplies", []},
         {"Toys", []},
         {"Food & Treats", []},
         {"Gifts & Books", []},
         {"New Arrivals", []}
       ]}
    ]
  }

  @brands {
    "Brands",
    [
      {"A Pet Hub", []},
      {"AA Aquarium", []},
      {"Absorbine", []},
      {"B Air", []},
      {"Banixx", []},
      {"Cadet", []},
      {"Calm Paws", []},
      {"Danner", []},
      {"Ecovet", []},
      {"Inaba", []},
      {"Max-Bone", []},
      {"Neko Chan", []}
    ]
  }

  def seed do
    Repo.delete_all(Taxonomy)
    TaxonomyHelper.create_taxonomy(@product_category)
    TaxonomyHelper.create_taxonomy(@brands)
  end
end
