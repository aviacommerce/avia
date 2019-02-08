defmodule AdminAppWeb.PaginationHelpers do
  import Phoenix.HTML
  import Phoenix.HTML.Form
  import Phoenix.HTML.Link
  import Phoenix.HTML.Tag

  def pagination_text(list) do
    content_tag :div, class: "text-primary" do
      "Displaying #{list.first}-#{list.last} of #{list.count}"
    end
  end

  def pagination_links(conn, list, route) do
    content_tag :div, class: "pagination" do
      children = []

      page_links =
        get_previous(children, conn, list, route) ++ get_next(children, conn, list, route)

      {:safe, page_links}
    end
  end

  defp get_previous(children, conn, list, route) do
    case list.has_prev do
      true ->
        {:safe, children} =
          children ++
            link("Previous",
              to: route.(conn, :index, "", %{"page" => list.prev_page}),
              class: "btn btn-primary btn-lg"
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
              to: route.(conn, :index, "", %{"page" => list.next_page}),
              class: "btn btn-primary btn-lg"
            )

        children

      false ->
        children
    end
  end
end
