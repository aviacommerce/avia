defmodule AdminAppWeb.Live.DataTable do
  import Phoenix.LiveView.Helpers

  def sort(%{"sort_field" => field, "sort_direction" => direction})
      when direction in ~w(asc desc) do
    %{field: String.to_existing_atom(field), order: String.to_existing_atom(direction)}    
  end

  def sort(_other), do: %{field: :id, order: :desc}

  def table_link(params, text, field) do
    direction = params["sort_direction"]

    opts =
      if params["sort_field"] == to_string(field) do
        [
          sort_field: field,
          sort_direction: reverse(direction)
        ]
      else
        [
          sort_field: field,
          sort_direction: "desc"
        ]
      end

    live_patch(text, to: "?" <> querystring(params, opts), class: "link flex items-center")
  end

  def querystring(params, opts \\ %{}) do
    params = params |> Plug.Conn.Query.encode() |> URI.decode_query()

    opts = %{
      "page" => opts[:page],
      "sort_field" => opts[:sort_field] || params["sort_field"] || nil,
      "sort_direction" => opts[:sort_direction] || params["sort_direction"] || nil
    }

    params
    |> Map.merge(opts)
    |> Enum.filter(fn {_, v} -> v != nil end)
    |> Enum.into(%{})
    |> URI.encode_query()
  end

  defp reverse("desc"), do: "asc"
  defp reverse(_), do: "desc"
end
