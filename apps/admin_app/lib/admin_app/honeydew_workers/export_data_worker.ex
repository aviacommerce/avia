defmodule Avia.ExportDataWorker do
  @behaviour Honeydew.Worker

  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias AdminAppWeb.Helpers

  def export_data(%{"tenant" => tenant, "format" => format, "type" => type, "user" => user}) do
    Repo.set_tenant(tenant)

    case format do
      "csv" ->
        Helpers.csv_exporter(user, type)

      "xlsx" ->
        Helpers.xlsx_exporter(user, type)
    end
  end
end
