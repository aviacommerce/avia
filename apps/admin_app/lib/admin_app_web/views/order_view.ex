defmodule AdminAppWeb.OrderView do
  use AdminAppWeb, :view

  @bootstrap_contextual_class %{
    "cart" => "light",
    "address" => "light",
    "payment" => "light",
    "processing" => "warning",
    "shipping" => "warning",
    "shipped" => "info",
    "cancelled" => "secondary",
    "completed" => "success"
  }

  @summary_fields ~w(item_total adjustment_total promo_total total)a
  @summary_fields_capitalized Enum.map(@summary_fields, fn field ->
                                field
                                |> Atom.to_string()
                                |> String.replace("_", " ")
                                |> String.capitalize()
                              end)
  @summary_field_classes %{
    total: "table-secondary"
  }

  def colorize(%{state: state}) do
    "table-" <> Map.fetch!(@bootstrap_contextual_class, state)
  end

  def state_badge(state) do
    color_class = @bootstrap_contextual_class[state]
    content_tag(:span, state, class: "badge badge-pill badge-#{color_class}")
  end

  defp render_line_item(line_item, state) do
    content = [
      render_variant(line_item.variant),
      content_tag(:td, line_item.unit_price),
      render_quantity_with_stock(line_item),
      content_tag(:td, Money.mult!(line_item.unit_price, line_item.quantity)),
      render_buttons(state)
    ]

    content_tag(:tr, List.flatten(content))
  end

  defp render_variant(variant) do
    [content_tag(:th, content_tag(:i, "", class: "far fa-image")), content_tag(:td, variant.sku)]
  end

  defp render_buttons(state) do
    if is_editable?(state) do
      content_tag(
        :td,
        content_tag(
          :button,
          [
            "edit ",
            content_tag(:span, tag(:i, class: "far fa-edit"), class: "badge badge-light")
          ],
          class: "btn btn-primary",
          onclick: "foo()"
        )
      )
    end
  end

  defp render_quantity_with_stock(line_item) do
    content_tag(:td, "#{line_item.quantity} x on hand")
  end

  defp render_address(address) do
    content_tag(
      :p,
      [
        "#{address.first_name} #{address.last_name}",
        address.address_line_1,
        address.address_line_2,
        address.city,
        address.phone,
        address.zip_code
      ]
      |> Enum.reject(&(&1 == nil))
      |> Enum.intersperse([",", tag(:br)])
      |> List.flatten(),
      class: "text-center"
    )
  end

  defp summary(order) do
    content_tag(
      :tbody,
      @summary_fields
      |> Stream.zip(@summary_fields_capitalized)
      |> Enum.map(&make_summary_row(&1, order))
    )
  end

  defp make_summary_row({field, field_capitalized}, order) do
    content_tag(
      :tr,
      [
        content_tag(:th, field_capitalized, scope: "row"),
        content_tag(:td, Map.fetch!(order, field))
      ],
      class: Map.get(@summary_field_classes, field)
    )
  end

  defp is_editable?(_), do: true
end
