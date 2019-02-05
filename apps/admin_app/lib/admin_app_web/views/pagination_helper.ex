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

      if list.has_prev do
        children =
          children ++
            link("Previous",
              to: route.(conn, :index, page: list.prev_page),
              class: "btn btn-secondary col-md-1"
            )
      end

      if list.has_next do
        children =
          children ++
            link("Next",
              to: route.(conn, :index, page: list.next_page),
              class: "btn btn-secondary col-md-1"
            )
      end

      children
    end
  end
end
