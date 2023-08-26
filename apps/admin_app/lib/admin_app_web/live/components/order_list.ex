defmodule AdminAppWeb.OrderListComponent do
  use Phoenix.LiveComponent
  import AdminAppWeb.OrderView
  import AdminAppWeb.Live.DataTable

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container">
      <table class="w-full text-sm text-left text-gray-500 dark:text-gray-400">
        <thead class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-700 dark:text-gray-400">
          <tr>
            <th scope="col" class="py-3 px-6">
              <%= table_link(@params, "ID" , :id) %>
            </th>
            <th scope="col" class="py-3 px-6">
              <%= table_link(@params, "Order Number" , :number) %>
            </th>
            <th scope="col" class="py-3 px-6">
              <%= table_link(@params, "Placed On" , :inserted_at) %>
            </th>
            <th scope="col" class="py-3 px-6">
              <%= table_link(@params, "State" , :state) %>
            </th>
            <th scope="col" class="py-3 px-6">
              Total
            </th>
          </tr>
        </thead>
        <tbody>
          <%= for order <- @orders.list do %>
            <tr class="bg-white border-b dark:bg-gray-800 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-600">
              <td class="py-4 px-6">
                <%= order.id %>
              </td>
              <th scope="row" class="py-4 px-6 font-medium text-blue-500 whitespace-nowrap dark:text-white">
                <a href={"/orders/#{order.number}/detail"} rel="nofollow">
                  #<%= order.number %>
                </a>
              </th>
              <td class="py-4 px-6">
                <%= order.inserted_at %>
              </td>
              <td class="py-4 px-6">
                <%= order.state %>
              </td>
              <td class="py-4 px-6">
                <%= order_total(order) %>
              </td>
            </tr>
            <% end %>
        </tbody>
      </table>
      <%= live_component AdminAppWeb.Live.PaginationComponent, params: @params, pagination_data: @orders %>
    </div>
    """
  end
end
