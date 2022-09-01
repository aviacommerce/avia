defmodule AdminAppWeb.OrderListCardComponent do
  use AdminAppWeb, :live_component
  import AdminAppWeb.OrderView

  @impl true
  def render(assigns) do
    ~H"""
    <div class="dark:bg-gray-1000 bg-gray-100 py-14 my-5 px-4 md:px-6 2xl:px-20 2xl:container 2xl:mx-auto">
      <div class="flex justify-start item-start space-y-2 flex-col">
        <h1 class="text-xl dark:text-white font-semibold leading-7 lg:leading-9 text-gray-800">Order #<%= @order.number %></h1>
        <p class="text-base dark:text-gray-300 font-medium leading-6 text-gray-600"><%= @order.inserted_at %></p>
      </div> 
      <div class="mt-10 flex flex-col xl:flex-row jusitfy-center items-stretch w-full xl:space-x-8 space-y-4 md:space-y-6 xl:space-y-0">
        <div class="flex flex-col justify-start items-start w-full space-y-4 md:space-y-6 xl:space-y-8">
          <div class="flex flex-col justify-start items-start dark:bg-gray-800 bg-gray-50 px-4 py-4 md:py-6 md:p-6 xl:p-8 w-full">
            <p class="text-lg md:text-xl dark:text-white font-semibold leading-6 xl:leading-5 text-gray-800">By <%= order_user_name(@order) %></p>
            <%= for line_item <- @order.line_items do %>
              <div class="mt-4 md:mt-6 flex flex-col md:flex-row justify-start items-start md:items-center md:space-x-6 xl:space-x-8 w-full">
                <div class="border-b border-gray-200 md:flex-row flex-col flex justify-between items-start w-full pb-8 space-y-4 md:space-y-0">
                  <div class="w-full flex flex-col justify-start items-start space-y-8">
                    <h3 class="text-md dark:text-white font-semibold leading-6 text-gray-800"><%= render_variant_name(line_item.product) %></h3>
                  </div>
                  <div class="flex justify-between space-x-8 items-start w-full">
                    <p class="text-base dark:text-white leading-6 text-gray-800"><%= render_quantity_with_stock(line_item) %></p>
                    <p class="text-base dark:text-white font-semibold leading-6 text-gray-800"><%= line_item_total(line_item) %></p>
                  </div>
                </div>
              </div>
            <% end %>
          </div>
        </div>
        <div class="flex justify-center flex-col md:flex-row flex-col items-stretch w-1/2 space-y-4 md:space-y-0 md:space-x-6 xl:space-x-8">
          <div class="flex flex-col px-4 py-6 md:p-6 xl:p-8 w-full bg-gray-50 dark:bg-gray-800 space-y-6">
            <h3 class="text-xl dark:text-white font-semibold leading-5 text-gray-800">Summary</h3>
            <div class="flex justify-center items-center w-full space-y-4 flex-col border-gray-200 border-b pb-4">
              <div class="flex justify-between w-full">
                <p class="text-base dark:text-white leading-4 text-gray-800">Subtotal</p>
                <p class="text-base dark:text-gray-300 leading-4 text-gray-600">$56.00</p>
              </div>
              <div class="flex justify-between items-center w-full">
                <p class="text-base dark:text-white leading-4 text-gray-800">Discount <span class="bg-gray-200 p-1 text-xs font-medium dark:bg-white dark:text-gray-800 leading-3 text-gray-800">STUDENT</span></p>
                <p class="text-base dark:text-gray-300 leading-4 text-gray-600">-$28.00 (50%)</p>
              </div>
              <div class="flex justify-between items-center w-full">
                <p class="text-base dark:text-white leading-4 text-gray-800">Shipping</p>
                <p class="text-base dark:text-gray-300 leading-4 text-gray-600">$8.00</p>
              </div>
            </div>
            <div class="flex justify-between items-center w-full">
              <p class="text-base dark:text-white font-semibold leading-4 text-gray-800">Total</p>
              <p class="text-base dark:text-gray-300 font-semibold leading-4 text-gray-600"><%= order_total(@order) %></p>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
