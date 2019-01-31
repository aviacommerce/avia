defmodule AdminAppWeb.Tax.TaxZoneController do
  @moduledoc false
  use AdminAppWeb, :controller
  alias Snitch.Data.Model.TaxZone
  alias Snitch.Data.Schema.TaxZone, as: TaxZoneSchema

  @default_layout_actions ~w(index new create)a

  plug(
    :put_layout,
    {AdminAppWeb.Tax.TaxConfigView, "tax_layout.html"} when action in @default_layout_actions
  )

  plug(
    :put_layout,
    {AdminAppWeb.Tax.TaxZoneView, "tax_zone_layout.html"}
    when action not in @default_layout_actions
  )

  def index(conn, _params) do
    tax_zones = TaxZone.get_all()
    render(conn, "index.html", tax_zones: tax_zones)
  end

  def new(conn, _params) do
    changeset = TaxZoneSchema.create_changeset(%TaxZoneSchema{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"tax_zone" => params}) do
    with {:ok, tax_zone} <- TaxZone.create(params) do
      redirect(conn, to: tax_zone_path(conn, :edit, tax_zone.id))
    else
      {:error, changeset} ->
        conn
        |> put_flash(:error, "There were some errors!")

        render(conn, "new.html", changeset: %{changeset | action: :insert})
    end
  end

  def edit(conn, %{"id" => id}) do
    with {:ok, tax_zone} <- TaxZone.get(id) do
      changeset = TaxZoneSchema.update_changeset(tax_zone, %{})
      render(conn, "edit.html", changeset: changeset, tax_zone: tax_zone)
    else
      {:error, _} ->
        conn
        |> put_flash(:error, "tax zone not found")

        redirect(conn, to: tax_zone_path(conn, :index))
    end
  end

  def update(conn, %{"id" => id, "tax_zone" => params}) do
    tax_zone = id |> TaxZone.get() |> get(conn)

    with {:ok, _config} <- TaxZone.update(tax_zone, params) do
      redirect(conn, to: tax_zone_path(conn, :index))
    else
      {:error, changeset} ->
        render(conn, "edit.html",
          changeset: %{changeset | action: :update},
          tax_zone: tax_zone
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, _data} <- id |> String.to_integer() |> TaxZone.delete() do
      conn
      |> put_flash(:info, "tax zone deleted")
      |> redirect(to: tax_zone_path(conn, :index))
    else
      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> redirect(to: tax_zone_path(conn, :index))
    end
  end

  defp get({:ok, config}, _conn), do: config

  defp get({:error, message}, conn) do
    conn
    |> put_flash(:error, message)
    |> redirect(to: tax_zone_path(conn, :index))
  end
end
