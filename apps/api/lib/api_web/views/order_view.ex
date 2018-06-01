defmodule ApiWeb.OrderView do
  use ApiWeb, :view

  alias ApiWeb.{PackageView, AddressView, LineItemView}

  @static_fields %{
    "ship_total" => "0.0",
    "email" => "admin@ofypets.com",
    "completed_at" => nil,
    "payment_total" => "0.0",
    "shipment_state" => nil,
    "payment_state" => nil,
    "channel" => "spree",
    "included_tax_total" => "0.0",
    "additional_tax_total" => "0.0",
    "tax_total" => "0.0",
    "considered_risky" => false,
    "canceler_id" => nil,
    "payments" => [],
    "adjustments" => [],
    "credit_cards" => [],
    "permissions" => %{
      "can_update" => true
    }
  }

  def render("order.json", %{order: order} = assigns) do
    order
    |> Map.from_struct()
    |> Map.drop(~w[user __meta__ billing_address shipping_address]a)
    |> Map.merge(%{
      item_total: order.item_total.amount,
      total: order.total.amount
    })
    |> Map.merge(render_order(order))
    |> Map.merge(render_addresses(assigns))
    |> Map.merge(@static_fields)
    |> Map.put(
      "shipments",
      render_many(Map.get(assigns, :packages, []), PackageView, "package.json")
    )
  end

  def render_order(order) do
    %{
      "number" => order.id,
      "created_at" => order.inserted_at,
      "display_included_tax_total" => Money.to_string!(Money.zero(:USD)),
      "display_additional_tax_total" => Money.to_string!(Money.zero(:USD)),
      "currency" => order.total.currency,
      "display_item_total" => Money.to_string!(order.item_total),
      "total_quantity" =>
        Enum.reduce(Enum.map(order.line_items, fn %{quantity: q} -> q end), 0, &+/2),
      "display_total" => Money.to_string!(order.item_total),
      "display_ship_total" => Money.to_string!(Money.zero(:USD)),
      "display_tax_total" => Money.to_string!(Money.zero(:USD)),
      "display_adjustment_total" => Money.to_string!(order.adjustment_total),
      "token" => order.id,
      "checkout_steps" => [
        "address",
        "delivery",
        "payment",
        "complete"
      ],
      "line_items" =>
        render_many(order.line_items, LineItemView, "line_item.json", as: :line_item)
    }
  end

  def render_addresses(%{order: _order, addresses: %{billing: b, shipping: s}}) do
    %{
      "bill_address" => render_one(b, AddressView, "address.json"),
      "ship_address" => render_one(s, AddressView, "address.json")
    }
  end

  def render_addresses(%{order: order}) do
    %{
      "bill_address" => render_one(order.billing_address, AddressView, "address.json"),
      "ship_address" => render_one(order.shipping_address, AddressView, "address.json")
    }
  end
end
