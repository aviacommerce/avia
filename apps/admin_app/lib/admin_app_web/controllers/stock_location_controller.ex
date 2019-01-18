defmodule AdminAppWeb.StockLocationController do
  use AdminAppWeb, :controller
  alias AdminAppWeb.DataHelpers
  alias Snitch.Domain.StockLocation, as: SLDomain
  alias Snitch.Data.Model.StockLocation, as: SLModel
  alias Snitch.Data.Schema.StockLocation, as: SLSchema
  alias Snitch.Data.Schema.Zone
  alias Snitch.Data.Model.CountryZone, as: CZone
  alias Snitch.Core.Tools.MultiTenancy.Repo

  def index(conn, _params) do
    data = %{stock_locations: SLDomain.search()}
    render(conn, :index, data)
  end

  def show(conn, %{"id" => id}) do
    with {id, _} <- Integer.parse(id),
         {:ok, stock_location} <- SLModel.get(id) do
      render(conn, "show.html", stock_location: stock_location)
    else
      _ ->
        conn
        |> put_flash(:error, "Stock Location not found")
        |> redirect(to: stock_location_path(conn, :index))
    end
  end

  def new(conn, _params) do
    changeset = SLSchema.create_changeset(%SLSchema{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"stock_location" => stock_location}) do
    with {:ok, location} <- SLModel.create(stock_location) do
      create_zone_for_location(location)

      conn
      |> put_flash(:info, "Stock Location created successfully")
      |> redirect(to: stock_location_path(conn, :index))
    else
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Error: Some validations failed")
        |> render("new.html", changeset: %{changeset | action: :insert})
    end
  end

  def fetch_country_states(conn, %{"country_id" => country_id}) do
    state_list = DataHelpers.formatted_list(country_id)

    conn
    |> put_status(200)
    |> json(%{state_list: state_list})
  end

  defp create_zone_for_location(location) do
    country_ids = [location.country_id]
    name = location.name <> "_zone"
    zones = Repo.all(Zone)

    check_zone_with_country =
      Enum.find(zones, fn zone -> Enum.member?(CZone.member_ids(zone), location.country_id) end)

    case check_zone_with_country do
      nil ->
        CZone.create(name, nil, country_ids)

      zone ->
        nil
    end
  end

  def edit(conn, %{"id" => id}) do
    with {id, _} <- Integer.parse(id),
         {:ok, stock_location} <- SLModel.get(id) do
      changeset = SLSchema.update_changeset(stock_location, %{})
      render(conn, "edit.html", changeset: changeset, stock_location: stock_location)
    else
      _ ->
        conn
        |> put_flash(:error, "Stock Location not found")
        |> redirect(to: stock_location_path(conn, :index))
    end
  end

  def update(conn, %{"id" => id, "stock_location" => stock_location_params}) do
    {id, _} = Integer.parse(id)
    {:ok, stock_location} = SLModel.get(id)

    with {:ok, _} <- SLModel.update(stock_location_params, stock_location) do
      conn
      |> put_flash(:info, "Stock Location updated successfully")
      |> redirect(to: stock_location_path(conn, :index))
    else
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Error: Some validations failed")
        |> render(
          "edit.html",
          changeset: %{changeset | action: :update},
          stock_location: stock_location
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    with {id, _} <- Integer.parse(id),
         {:ok, _} <- SLModel.delete(id) do
      conn
      |> put_flash(:info, "Stock Location deleted successfully")
      |> redirect(to: stock_location_path(conn, :index))
    else
      {:error, _} ->
        conn
        |> put_flash(:error, "Stock Location not found")
        |> redirect(to: stock_location_path(conn, :index))
    end
  end
end
