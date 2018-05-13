defmodule Snitch.Tools.Helpers.Taxonomy do
  use ExUnit.Case, async: false
  use Snitch.DataCase

  alias Snitch.Tools.Helper.Taxonomy, as: TaxonomyHelper
  alias Snitch.Domain.Taxonomy, as: TaxonomyDomain
  alias Snitch.Repo

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
        TaxonomyHelper.create_taxonomy(@brands_taxonomy)
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
        TaxonomyHelper.create_taxonomy({"Root", []})
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
