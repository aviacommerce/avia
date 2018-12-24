defmodule Avia.ExportDataWorker do
  @behaviour Honeydew.Worker

  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias AdminAppWeb.Exporter

  def export_data(%{"tenant" => tenant, "format" => format, "type" => type, "user" => user}) do
    Repo.set_tenant(tenant)

    case format do
      "csv" ->
        Exporter.csv_exporter(user, type)

      "xlsx" ->
        Exporter.xlsx_exporter(user, type)
    end
  end
end
