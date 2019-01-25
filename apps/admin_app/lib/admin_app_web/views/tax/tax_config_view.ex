defmodule AdminAppWeb.Tax.TaxConfigView do
  use AdminAppWeb, :view
  import AdminAppWeb.LayoutView, only: [render_layout: 3]
  alias Snitch.Data.Model.TaxConfig

  def active_link(conn, route) do
    if conn.request_path == route do
      "active"
    else
      ""
    end
  end

  def address_types() do
    TaxConfig.tax_address_types()
  end
end
