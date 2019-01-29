defmodule AdminAppWeb.PropertyController do
  use AdminAppWeb, :controller

  alias Snitch.Data.Model.Property, as: PropertyModel
  alias Snitch.Data.Schema.Property, as: PropertySchema
  alias Snitch.Data.Model

  def index(conn, _params) do
    properties = PropertyModel.get_all()
    render(conn, "index.html", %{properties: properties})
  end

  def new(conn, params) do
    changeset = PropertySchema.create_changeset(%PropertySchema{}, params)
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"property" => params}) do
    case PropertyModel.create(params) do
      {:ok, _} ->
        redirect(conn, to: property_path(conn, :index))

      {:error, changeset} ->
        render(conn, "new.html", changeset: %{changeset | action: :new})
    end
  end

  def edit(conn, %{"id" => id}) do
    with {id, _} <- Integer.parse(id),
         {:ok, %PropertySchema{} = property} <- PropertyModel.get(id) do
      changeset = PropertySchema.update_changeset(property, %{})
      render(conn, "edit.html", changeset: changeset)
    else
      err when err in [:error, nil] ->
        conn
        |> put_flash(:info, "Property not found")
        |> redirect(to: property_path(conn, :index))
    end
  end

  def update(conn, %{"id" => id, "property" => params}) do
    with {id, _} <- Integer.parse(id),
         {:ok, property} <- PropertyModel.get(id),
         {:ok, _} <- PropertyModel.update(property, params) do
      properties = PropertyModel.get_all()
      render(conn, "index.html", %{properties: properties})
    else
      {:error, changeset} ->
        render(conn, "edit.html", changeset: %{changeset | action: :edit})

      :error ->
        conn
        |> put_flash(:info, "Property not found")
        |> redirect(to: property_path(conn, :index))
    end
  end

  def delete(conn, %{"id" => id}) do
    with {id, _} <- Integer.parse(id),
         true <- Model.ProductProperty.get_all_by_property(id) == [],
         {:ok, property} <- PropertyModel.delete(id) do
      conn
      |> put_flash(:info, "Property #{property.name} deleted successfully")
      |> redirect(to: property_path(conn, :index))
    else
      {:error, _} ->
        conn
        |> put_flash(:error, "Failed to delete property")
        |> redirect(to: property_path(conn, :index))

      false ->
        conn
        |> put_flash(:error, "Property with associated products cannot be deleted")
        |> redirect(to: property_path(conn, :index))

      :error ->
        conn
        |> halt()
        |> put_flash(:info, "Property not found")
        |> redirect(to: property_path(conn, :index))
    end
  end
end
