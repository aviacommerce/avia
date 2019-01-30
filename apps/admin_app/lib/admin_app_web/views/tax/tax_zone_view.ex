defmodule AdminAppWeb.Tax.TaxZoneView do
  use AdminAppWeb, :view
  import AdminAppWeb.LayoutView, only: [render_layout: 3]
  alias Snitch.Core.Tools.MultiTenancy.Repo

  def active_link(conn, route) do
    if conn.request_path == route do
      "active"
    else
      ""
    end
  end

  def tax_zone_id(conn) do
    conn.params["id"] || conn.params["tax_zone_id"]
  end

  def zone_type(tax_zone) do
    tax_zone = Repo.preload(tax_zone, :zone)
    get_zone_type(tax_zone.zone.zone_type)
  end

  defp get_zone_type("S"), do: "State"
  defp get_zone_type("C"), do: "Country"
end
