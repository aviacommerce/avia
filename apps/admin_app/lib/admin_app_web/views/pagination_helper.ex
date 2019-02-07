defmodule AdminAppWeb.PaginationHelpers do
  import Phoenix.HTML
  import Phoenix.HTML.Form
  import Phoenix.HTML.Link
  import Phoenix.HTML.Tag

  def pagination_text(list) do
    # ~e"""
    # Displaying <%= List.first(list) %>-<%= List.last(list) %> of <%= length(list) %>
    # """
  end

  def pagination_links(conn, list, route) do
    content_tag :div, class: "pagination" do
      children = []
      abc = get_previous(children, conn, list, route) ++ get_next(children, conn, list, route)
      {:safe, abc}
    end
  end

  defp get_previous(children, conn, list, route) do
    case list.has_prev do
      true ->
        {:safe, children} =
          children ++
            link("Previous",
              to: route.(conn, :index, "?page=#{list.prev_page}"),
              class: "btn btn-secondary btn-lg"
            )

        children

      false ->
        children
    end
  end

  defp get_next(children, conn, list, route) do
    case list.has_next do
      true ->
        {:safe, children} =
          children ++
            link("Next",
              to: route.(conn, :index, "?page=#{list.next_page}"),
              class: "btn btn-secondary btn-lg"
            )

        children

      false ->
        children
    end
  end
end
