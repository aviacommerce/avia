defmodule Avia.ExportOrderWorker do
  @behaviour Honeydew.Worker

  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias AdminAppWeb.Helpers

  def export_order(%{"tenant" => tenant, "type" => type, "user" => user}) do
    Repo.set_tenant(tenant)

    case type do
      "csv" ->
        Helpers.order_csv_exporter(user)

      "xlsx" ->
        Helpers.order_xlsx_exporter(user)
    end
  end
end
