defmodule ApiWeb.CheckoutController do
  use ApiWeb, :controller

  alias BeepBop.Context
  alias Snitch.Data.Model.{Order, State, Country}
  alias Snitch.Data.Schema.Address
  alias Snitch.Domain.Order.DefaultMachine
  alias Snitch.Repo
  alias ApiWeb.FallbackController, as: Fallback
  alias ApiWeb.OrderView

  def next(conn, params) do
    id = String.to_integer(params["order_id"])
    order = Order.get(%{id: id})
    do_next(conn, order)
  end

  def do_next(conn, %{state: "cart"}) do
    json(conn, %{})
  end

  def do_next(conn, %{state: "address"}) do
    json(conn, %{})
  end

  def add_addresses(conn, %{"order_id" => order_id, "order" => addresses}) do
    id =
      order_id
      |> List.first()
      |> String.split(".")
      |> List.first()
      |> String.to_integer()

    %{
      # "bill_address_attributes" => billing,
      "ship_address_attributes" => shipping
    } = addresses

    shipping = translate_fields(shipping)
    # {:ok, billing_state} = State.get(%{id: billing["state_id"]})
    # {:ok, billing_country} = Country.get(%{id: billing_state.country_id})

    shipping_state = State.get(%{id: shipping.state_id})
    shipping_country = Country.get(%{id: shipping_state.country_id})

    # billing_cs = Address.create_changeset(%Address{}, billing, billing_country, billing_state)
    shipping_cs = Address.create_changeset(%Address{}, shipping, shipping_country, shipping_state)

    context =
      %{id: id}
      |> Order.get()
      |> Repo.preload(line_items: [:variant])
      |> Context.new(state: %{billing_cs: shipping_cs, shipping_cs: shipping_cs})
      |> DefaultMachine.add_addresses()

    case context do
      %{valid?: true, state: state, multi: %{packages: packages, persist: order}} ->
        conn
        |> put_view(OrderView)
        |> render(
          "order.json",
          order: order,
          packages: Repo.preload(packages, :origin),
          addresses: state
        )

      %{valid?: false, multi: errors} ->
        Fallback.call(conn, errors)

      {:error, error} ->
        Fallback.call(conn, {:error, error})
    end
  end

  defp translate_fields(params) do
    %{
      first_name: params["firstname"],
      last_name: params["lastname"],
      address_line_1: params["address1"],
      address_line_2: params["address2"],
      zip_code: params["zipcode"],
      city: params["city"],
      phone: params["phone"],
      state_id: params["state_id"],
      country_id: params["country_id"]
    }
  end
end
