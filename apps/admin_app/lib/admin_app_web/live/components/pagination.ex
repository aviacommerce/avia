defmodule AdminAppWeb.Live.PaginationComponent do
  use Phoenix.LiveComponent
  import AdminAppWeb.Live.DataTable

  @distance 5

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(pagination_assigns(assigns[:pagination_data]))
    }
  end

  def render(assigns) do
    ~H"""
    <nav id={@id || "pagination"} class="flex justify-between items-center pt-4" aria-label="Table navigation">
      <span class="text-sm font-normal text-gray-500 dark:text-gray-400">
        Showing 
        <span class="font-semibold text-gray-900 dark:text-white">
          <%= @showing_from %>-<%= @showing_to %>
        </span>
        of 
        <span class="font-semibold text-gray-900 dark:text-white">
          <%= @total_entries %>
        </span>
      </span>
      <ul class="inline-flex items-center -space-x-px">
        <%= if @total_pages > 1 do %>
          <li><%= prev_link(@params, @page_number) %></li>
          <%= for num <- start_page(@page_number)..end_page(@page_number, @total_pages) do %>
            <li>
              <%= live_patch num,
                to: "?#{querystring(@params, page: num)}",
                class: if @page_number == num, do: "z-10 py-2 px-3 leading-tight text-blue-600 bg-blue-50 border border-blue-300 hover:bg-blue-100 hover:text-blue-700 dark:border-gray-700 dark:bg-gray-700 dark:text-white", else: "py-2 px-3 leading-tight text-gray-500 bg-white border border-gray-300 hover:bg-gray-100 hover:text-gray-700 dark:bg-gray-800 dark:border-gray-700 dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-white"
              %>
            </li>
          <% end %>
          <li><%= next_link(@params, @page_number, @total_pages) %></li>
        <% end %>
      </ul>
    </nav>
    """
  end

  defp pagination_assigns(pagination) do
    [
      page_number: pagination.page,
      page_size: pagination.per_page,
      total_entries: pagination.count,
      total_pages: pagination.max_page,
      showing_from: pagination.first,
      showing_to: pagination.last
    ]
  end

  def prev_link(conn, current_page) do
    class =
      "py-2 px-3 ml-0 leading-tight text-gray-500 bg-white rounded-l-lg border border-gray-300 hover:bg-gray-100 hover:text-gray-700 dark:bg-gray-800 dark:border-gray-700 dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-white"

    class_disabled = class <> " disabled"

    if current_page != 1 do
      live_patch("Prev", to: "?" <> querystring(conn, page: current_page - 1), class: class)
    else
      live_patch("Prev", to: "#", class: class_disabled)
    end
  end

  def next_link(conn, current_page, num_pages) do
    class =
      "py-2 px-3 leading-tight text-gray-500 bg-white rounded-r-lg border border-gray-300 hover:bg-gray-100 hover:text-gray-700 dark:bg-gray-800 dark:border-gray-700 dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-white"

    class_disabled = class <> " disabled"

    if current_page != num_pages do
      live_patch("Next", to: "?" <> querystring(conn, page: current_page + 1), class: class)
    else
      live_patch("Next", to: "#", class: class_disabled)
    end
  end

  def start_page(current_page) when current_page - @distance <= 0, do: 1
  def start_page(current_page), do: current_page - @distance

  def end_page(current_page, 0), do: current_page

  def end_page(current_page, total)
      when current_page <= @distance and @distance * 2 <= total do
    @distance * 2
  end

  def end_page(current_page, total) when current_page + @distance >= total do
    total
  end

  def end_page(current_page, _total), do: current_page + @distance - 1
end
