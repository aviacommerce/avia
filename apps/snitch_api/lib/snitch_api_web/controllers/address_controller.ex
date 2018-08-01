defmodule SnitchApiWeb.AddressController do
  use SnitchApiWeb, :controller

  alias SnitchApi.Checkout
  alias Snitch.Data.Schema.Address

  action_fallback(SnitchApiWeb.FallbackController)
  plug(SnitchApiWeb.Plug.DataToAttributes)
  plug(SnitchApiWeb.Plug.LoadUser)

  def index(conn, params) do
    addresses = Checkout.list_addresses(conn, params)

    render(
      conn,
      "index.json-api",
      data: addresses,
      opts: [include: "country,country.states,state"]
    )
  end

  def create(conn, address_params) do
    with {:ok, %Address{} = address} <- Checkout.create_address(address_params) do
      conn
      |> put_status(200)
      |> put_resp_header("location", address_path(conn, :show, address))
      |> render("show.json-api", data: address)
    end
  end

  def show(conn, %{"id" => id}) do
    address = Checkout.get_address!(id)
    render(conn, "show.json-api", address: address)
  end

  def update(conn, %{"id" => id, "address" => address_params}) do
    address = Checkout.get_address!(id)
    address_params = JaSerializer.Params.to_attributes(address_params)

    with {:ok, %Address{} = address} <- Checkout.update_address(address, address_params) do
      render(conn, "show.json-api", address: address)
    end
  end

  def delete(conn, %{"id" => id}) do
    address = Checkout.get_address!(id)

    with {:ok, %Address{}} <- Checkout.delete_address(address) do
      conn
      |> put_status(204)
      |> send_resp(:no_content, "")
    end
  end
end
