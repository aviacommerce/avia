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

  def seed() do
    TaxonomyHelper.create_taxonomy(@brands_taxonomy)
    TaxonomyHelper.create_taxonomy(@footwear_taxonomy)
  end
end
