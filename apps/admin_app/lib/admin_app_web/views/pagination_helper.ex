defmodule AdminAppWeb.PaginationHelpers do
  @moduledoc """
  Helper functions to generate links on the frontend according to the information 
  in paginated queries.
  """
  import Phoenix.HTML
  import Phoenix.HTML.Form
  import Phoenix.HTML.Link
  import Phoenix.HTML.Tag

  def pagination_text(list) do
    content_tag :div, class: "text-primary" do
      "Displaying #{list.first}-#{list.last} of #{list.count}"
    end
  end

  defp fetch_params(%Plug.Conn.Unfetched{} = params) do
    %{}
  end

  defp fetch_params(params) do
    params
  end

  def pagination_links(conn, list, route) do
    params = fetch_params(conn.params)

    content_tag :div, class: "pagination", data: [category: params["category"]] do
      page_links = get_previous(conn, params, list, route) ++ get_next(conn, params, list, route)

      {:safe, page_links}
    end
  end

  defp get_previous(conn, params, list, route) do
    case list.has_prev do
      true ->
        {:safe, children} =
          link("Previous",
            to: '#',
            class: "pagination-btn btn btn-primary btn-lg previous",
            data: [
              page: list.prev_page,
              route: route.(conn, :index, Map.put(params, "page", list.prev_page))
            ]
          )

        children

      false ->
        []
    end
  end

  defp get_next(conn, params, list, route) do
    case list.has_next do
      true ->
        {:safe, children} =
          link("Next",
            to: '#',
            class: "pagination-btn btn btn-primary btn-lg next",
            data: [
              page: list.next_page,
              route: route.(conn, :index, Map.put(params, "page", list.next_page))
            ]
          )

        children

      false ->
        []
    end
  end
end
