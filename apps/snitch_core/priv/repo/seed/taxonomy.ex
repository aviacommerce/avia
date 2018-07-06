defmodule Snitch.Seed.Taxonomy do
  @moduledoc """
  Seeds basic taxonomy.

  Following is the taxonomy generated.

      Brands
      └── Bags
      └── Mugs
      └── Clothing
          └── Shirts
          └── T-Shirts

      Footwear
      ├── Men
      |   └── Casual Shoes
      |   └── Sports Shoes
      |   └── Formal Shoes
      |   └── Sandal & Floaters
      |   └── Flip Flops
      ├── Women
          └── Flats & Casual Shoes
          └── Heels
          └── Boots
          └── Sports Shoes and Floaters
  """

  alias Snitch.Data.Schema.Taxonomy
  alias Snitch.Repo
  alias Snitch.Tools.Helper.Taxonomy, as: TaxonomyHelper

  @brands_taxonomy {"Brands",
                    [
                      {"Bags", []},
                      {"Mugs", []},
                      {"Clothing",
                       [
                         {"Shirts", []},
                         {"T-Shirts", []}
                       ]}
                    ]}

  @footwear_taxonomy {"Footwear",
                      [
                        {"Men",
                         [
                           {"Casual Shoes", []},
                           {"Sports Shoes", []},
                           {"Formal Shoes", []},
                           {"Sandal & Floaters", []},
                           {"Flip Flops", []}
                         ]},
                        {"Women",
                         [
                           {"Flats & Casual Shoes", []},
                           {"Heels", []},
                           {"Boots", []},
                           {"Sports Shoes and Floaters", []}
                         ]}
                      ]}

  @ofy_pets {
    "Pets",
    [
      {"Dog",
       [
         {"Food", []},
         {"Treat", []},
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
    TaxonomyHelper.create_taxonomy(@ofy_pets)
    TaxonomyHelper.create_taxonomy(@brands)
  end
end
