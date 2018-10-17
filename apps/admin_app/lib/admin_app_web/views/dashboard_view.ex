defmodule AdminAppWeb.DashboardView do
  use AdminAppWeb, :view

  alias AdminAppWeb.Helpers

  def get_date(params, key) do
    Helpers.get_date_from_params(params, key)
  end
end
