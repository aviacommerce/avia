defmodule ApiWeb.TaxonomyView do
  use ApiWeb, :view

  def render("taxonomy.json", assign) do
    %{taxonomies: assign.taxonomy}
  end
end
