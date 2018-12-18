defmodule Avia.CategoryWorker do
  @behaviour Honeydew.Worker

  alias Snitch.Domain.Taxonomy
  alias Snitch.Core.Tools.MultiTenancy.Repo

  def delete_cateory(%{"taxon_id" => taxon_id, "tenant" => tenant}) do
    Repo.set_tenant(tenant)
    Taxonomy.delete_taxon(taxon_id)
  end
end
