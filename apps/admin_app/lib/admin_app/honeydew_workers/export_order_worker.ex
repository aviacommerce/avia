defmodule Avia.ExportOrderWorker do
    @behaviour Honeydew.Worker

    alias Snitch.Core.Tools.MultiTenancy.Repo
    alias AdminAppWeb.Helpers
  
    def export_order(%{"tenant" => tenant, "type" => type}) do
      Repo.set_tenant(tenant)
      case type do
        "csv" ->
            Helpers.order_csv_exporter
        "xlsx" ->
            Helpers.order_xlsx_exporter
      end
    end
end
  