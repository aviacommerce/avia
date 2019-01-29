defmodule SnitchApiWeb.AddressController do
  use SnitchApiWeb, :controller

  alias SnitchApi.Checkout
  alias Snitch.Data.Schema.Address
  alias Snitch.Data.Model.{Country, CountryZone}
  alias Snitch.Core.Tools.MultiTenancy.Repo

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

  def update(conn, address_params) do
    id = address_params["id"]

    address =
      Checkout.get_address!(id)
      |> Repo.preload([:country, :state])

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

  def countries(conn, _params) do
    zones = CountryZone.get_all()

    countries =
      zones
      |> Enum.map(&CountryZone.members/1)
      |> List.flatten()
      |> Enum.uniq()
      |> Enum.sort_by(& &1.name)

    render(conn, SnitchApiWeb.CountryView, "index.json-api", data: countries)
  end

  def country_states(conn, %{"id" => country_id}) do
    case Country.get(country_id) do
      {:error, msg} ->
        conn
        |> put_status(msg)
        |> render(SnitchApiWeb.ErrorView, :"404")

      {:ok, country} ->
        country_with_states = Repo.preload(country, :states)

        render(
          conn,
          SnitchApiWeb.CountryView,
          "show.json-api",
          data: country_with_states,
          opts: [include: "states"]
        )
    end
  end
end
