defmodule Snitch.Tools.Helpers.TaxonomyTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  alias Snitch.Domain.Taxonomy, as: TaxonomyDomain
  alias Snitch.Core.Tools.MultiTenancy.Repo
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

  describe "create_taxonomy/1" do
    test "create valid taxonomy" do
      taxonomy =
        @brands_taxonomy
        |> TaxonomyHelper.create_taxonomy()
        |> Repo.preload(:root)

      taxonomy = dump_taxonomy(taxonomy.root)

      assert {%{name: "Brands"},
              [
                {%{name: "Bags"}, []},
                {%{name: "Mugs"}, []},
                {%{name: "Clothing"},
                 [
                   {%{name: "Shirts"}, []},
                   {%{name: "T-Shirts"}, []}
                 ]}
              ]} = taxonomy
    end

    test "create single node taxonomy" do
      taxonomy =
        {"Root", []}
        |> TaxonomyHelper.create_taxonomy()
        |> Repo.preload(:root)

      taxonomy = dump_taxonomy(taxonomy.root)
      assert {%{name: "Root"}, []} = taxonomy
    end
  end

  defp dump_taxonomy(taxon) do
    taxon
    |> TaxonomyDomain.get_root()
    |> TaxonomyDomain.dump_taxonomy()
  end
end
