defmodule AdminAppWeb.DashboardView do
  use AdminAppWeb, :view

  alias AdminAppWeb.Helpers

  def get_date(params, key) do
    get_time(params, key, params[key])
  end

  defp get_time(params, "from", nil) do
    start_time = Ecto.DateTime.utc()

    %{start_time | month: start_time.month - 1}
    |> Ecto.DateTime.to_date()
    |> to_string
  end

  defp get_time(params, "from", param_key) do
    Helpers.get_date_from_params(params, "from")
  end

  defp get_time(params, key, param_key) do
    Helpers.get_date_from_params(params, key)
  end
end
