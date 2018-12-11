defmodule Snitch.Demo.Taxonomy do
  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias Snitch.Data.Schema.{Product, Taxonomy, Variant}
  alias Snitch.Tools.Helper.Taxonomy, as: TaxonomyHelper

  @product_category {
    "Category",
    [
      {
        "Men's Fashion",
        [
          {"Clothing",
           [
             {"Cotton", []},
             {"Denim", []},
             {"Woolen", []}
           ]},
          {"Shirts",
           [
             {"Khadi", []},
             {"Denim", []},
             {"Cotton", []}
           ]},
          {"Watches",
           [
             {"Leather Strap", []},
             {"Metal Strap", []},
             {"ChronoGraphs", []},
             {"Digital Display", []},
             {"Analog Display", []}
           ]}
        ]
      },
      {
        "Women's Fashion",
        [
          {"Western Wear",
           [
             {"Dresses", []},
             {"Shirts, Tops & Tees", []},
             {"Trousers & Capris", []}
           ]},
          {"Ethnic Wear",
           [
             {"Sarees", []},
             {"Salwar Suits", []},
             {"Kurtas & Kurtis", []}
           ]},
          {"Watches",
           [
             {"Leather Strap", []},
             {"Metal Strap", []},
             {"SmartWatches", []},
             {"Digital Display", []},
             {"Analog Display", []}
           ]}
        ]
      },
      {
        "Kids",
        [
          {"Kids Costumes", []},
          {"Toys", []},
          {"Kids Footwear", []}
        ]
      },
      {
        "Beauty, Health, Grocery",
        [
          {"Beauty & Grooming", []},
          {"Luxury Beauty", []},
          {"Make-up", []},
          {"Health & Personal Care", []},
          {"Diet & Nutrition", []},
          {"Snack Foods", []}
        ]
      },
      {
        "Books",
        [
          {"Fiction Books", []},
          {"School Texbooks", []},
          {"Children's Books", []},
          {"Used Books", []}
        ]
      }
    ]
  }

  def create_taxonomy do
    Repo.delete_all(Product)
    Repo.delete_all(Variant)
    Repo.delete_all(Taxonomy)
    TaxonomyHelper.create_taxonomy(@product_category)
  end
end
