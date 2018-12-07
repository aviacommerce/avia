defmodule AdminAppWeb.StockLocationController do
  use AdminAppWeb, :controller
  alias Snitch.Domain.StockLocation, as: SLDomain
  alias Snitch.Data.Model.StockLocation, as: SLModel
  alias Snitch.Data.Schema.StockLocation, as: SLSchema
  alias Snitch.Data.Model.CountryZone, as: CZone

  def index(conn, _params) do
    data = %{stock_locations: SLDomain.search()}
    render(conn, :index, data)
  end

  def show(conn, %{"id" => id}) do
    with {id, _} <- Integer.parse(id),
         stock_location <- SLModel.get(id),
         false <- is_nil(stock_location) do
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

  defp create_zone_for_location(location) do
    country_ids = [location.country_id]
    name = location.name <> "_zone"
    CZone.create(name, nil, country_ids)
  end

  def edit(conn, %{"id" => id}) do
    with {id, _} <- Integer.parse(id),
         stock_location <- SLModel.get(id),
         false <- is_nil(stock_location) do
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
    stock_location = SLModel.get(id)

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
