defmodule AdminAppWeb.OrderView do
  use AdminAppWeb, :view
  alias Snitch.Data.Model.{Country, State}
  alias Snitch.Domain.Order, as: OrderDomain
  alias AdminAppWeb.Helpers
  alias SnitchPayments.PaymentMethodCode

  @bootstrap_contextual_class %{
    "slug" => "light",
    "cart" => "light",
    "address" => "light",
    "payment" => "light",
    "processing" => "warning",
    "shipping" => "warning",
    "shipped" => "info",
    "cancelled" => "secondary",
    "completed" => "success"
  }

  def order_user_name(order) do
    order.user.first_name <> order.user.last_name
  end

  def order_item_count(order) do
    case length(order.line_items) do
      1 ->
        "1 item"

      items ->
        items <> " items"
    end
  end

  def format_date(date) do
    Helpers.format_date(date)
  end

  def get_country_state(order) do
    country = get_country(order.shipping_address.country_id)
    state = get_state(order.shipping_address.state_id)
    state.name <> ", " <> country.name
  end

  def colorize(%{state: state}) do
    "table-" <> Map.fetch!(@bootstrap_contextual_class, state)
  end

  def state_badge(state) do
    color_class = @bootstrap_contextual_class[state]
    content_tag(:span, state, class: "badge badge-pill badge-#{color_class}")
  end

  defp render_line_item(line_item, order) do
    content = [
      render_variant(line_item.product),
      content_tag(:td, line_item.unit_price),
      render_quantity_with_stock(line_item)
    ]

    content_tag(:tr, List.flatten(content))
  end

  def render_variant(product) do
    content_tag(:td, product.sku)
  end

  def render_variant_name(product) do
    content_tag(:td, product.name)
  end

  def line_item_total(line_item) do
    Money.mult!(line_item.unit_price, line_item.quantity)
  end

  def order_items_total(order) do
    order
    |> OrderDomain.total_amount()
    |> Money.to_string!()
  end

  def tax_total(order) do
    order.packages
    |> OrderDomain.total_tax()
    |> Money.to_string!()
  end

  def shipping_total(order) do
    order.packages
    |> OrderDomain.shipping_total()
    |> Money.to_string!()
  end

  def shipping_method(order) do
    package = List.first(order.packages)
    String.capitalize(package.shipping_method.name)
  end

  defp render_update_buttons(item, order) do
    if is_editable?(order.state) do
      content_tag(
        :td,
        form_tag "/orders/#{order.number}/cart/edit?update=#{item}", method: "post" do
          content_tag(:button, ["update"], class: "btn btn-primary", type: "submit")
        end
      )
    end
  end

  defp render_buttons(item, order) do
    if is_editable?(order.state) do
      content_tag(
        :td,
        form_tag "/orders/#{order.number}/cart?edit=#{item}", method: "post" do
          content_tag(:button, ["remove"], class: "btn btn-primary", type: "submit")
        end
      )
    end
  end

  def render_quantity_with_stock(line_item) do
    content_tag(:td, "#{line_item.quantity}")
  end

  def render_address(address) do
    content_tag(:div, [
      content_tag(:div, ["#{address.first_name} #{address.last_name}"], class: "name"),
      content_tag(
        :div,
        [
          address.address_line_1,
          address.address_line_2,
          address.city,
          address.phone,
          address.zip_code
        ]
        |> Enum.reject(&(&1 == nil))
        |> Enum.intersperse([",", tag(:br)])
        |> List.flatten(),
        class: "addres-detail"
      )
    ])
  end

  defp is_editable?(_), do: true

  defp render_search_item(item, order) do
    content = [
      content_tag(:td, item.sku),
      content_tag(:td, item.selling_price),
      content_tag(:td, tag(:input, name: "quantity", id: "quantity")),
      content_tag(:td, content_tag(:button, ["Add"], type: "submit"))
    ]

    list =
      form_tag "/orders/#{order.number}/cart?add=#{item.id}", method: "put" do
        List.flatten(content)
      end

    content_tag(:tr, list)
  end

  def render_update_item(item, order) do
    content = [
      content_tag(:td, item.product.sku),
      content_tag(:td, item.product.selling_price),
      content_tag(:td, tag(:input, name: "quantity", value: item.quantity)),
      content_tag(:td, tag(:hidden, name: "product_id", value: item.product_id)),
      content_tag(:td, content_tag(:button, ["Add"], type: "submit"))
    ]

    list =
      form_tag "/orders/#{order.number}/cart/update?update=#{item.id}", method: "put" do
        List.flatten(content)
      end

    content_tag(:tr, list)
  end

  def build_address(address, order) do
    content = [
      content_tag(:td, address.first_name),
      content_tag(:td, address.last_name),
      content_tag(:td, address.address_line_1),
      content_tag(:td, address.phone),
      content_tag(:td, address.city),
      content_tag(
        :td,
        content_tag(:button, ["Attach"], type: "submit", class: "btn btn-sm btn-primary")
      )
    ]

    list =
      form_tag "/orders/#{order.number}/address/search?address_id=#{address.id}", method: "put" do
        List.flatten(content)
      end

    content_tag(:tr, list)
  end

  def display_email(order) do
    if order.user do
      order.user.email
    else
      "Guest Order"
    end
  end

  def check_for_cod(order) do
    Enum.any?(order.payments, fn payment ->
      payment.payment_type == PaymentMethodCode.cash_on_delivery()
    end)
  end

  def cod_status(order) do
    cod_payment =
      Enum.find(order.payments, fn payment ->
        payment.payment_type == PaymentMethodCode.cash_on_delivery()
      end)

    case cod_payment.state do
      "paid" ->
        %{display: "Mark as Unpaid", state: "pending"}

      _ ->
        %{display: "Mark as Paid", state: "paid"}
    end
  end

  defp render_invoice_line_item(line_item, order) do
    content = [
      render_variant_name(line_item.product),
      render_quantity(line_item),
      content_tag(:td, " #{line_item.unit_price} ")
    ]

    content_tag(:tr, List.flatten(content))
  end

  defp render_quantity(line_item) do
    content_tag(:td, " x #{line_item.quantity}")
  end

  def get_country(country_id) do
    Country.get(country_id)
  end

  def get_state(state_id) do
    State.get(state_id)
  end

  defp get_state_name(state_id) do
    state_id |> get_state() |> Map.get(:name)
  end

  defp get_iso(country_id) do
    country_id |> get_country() |> Map.get(:iso)
  end

  def order_total(order) do
    {:ok, total} = Money.to_string(OrderDomain.total_amount(order))
    total
  end

  def get_support_url() do
    Application.get_env(:admin_app, AdminAppWeb.Endpoint)[:support_url]
  end

  def get_support_email() do
    Application.get_env(:admin_app, AdminAppWeb.Endpoint)[:support_email]
  end
end
