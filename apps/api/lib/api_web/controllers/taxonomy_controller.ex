defmodule ApiWeb.TaxonomyController do
  use ApiWeb, :controller

  alias Snitch.Domain.Taxonomy

  def index(conn, _params) do
    taxonomy = Taxonomy.get_all_taxonomy()
    render(conn, "taxonomy.json", taxonomy: taxonomy)
  end
end
