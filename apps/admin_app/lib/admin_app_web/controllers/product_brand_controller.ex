defmodule AdminAppWeb.ProductBrandController do
  use AdminAppWeb, :controller

  alias Snitch.Data.Model.ProductBrand, as: ProductBrandModel
  alias Snitch.Data.Schema.ProductBrand, as: ProductBrandSchema

  def index(conn, params) do
    product_brands = ProductBrandModel.get_all()
    render(conn, "index.html", brands: product_brands)
  end

  def new(conn, _params) do
    changeset = ProductBrandSchema.create_changeset(%ProductBrandSchema{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"product_brand" => params}) do
    with {:ok, brand} <- ProductBrandModel.create(params) do
      redirect(conn, to: product_brand_path(conn, :index))
    else
      {:error, changeset} ->
        render(conn, "new.html", changeset: %{changeset | action: :new})
    end
  end

  def edit(conn, %{"id" => id}) do
    with %ProductBrandSchema{} = brand <- ProductBrandModel.get(id),
         changeset <- ProductBrandSchema.update_changeset(brand, %{}) do
      render(conn, "edit.html", changeset: changeset)
    else
      nil ->
        conn
        |> put_flash(:info, "Product Brand not found")
        |> redirect(to: product_brand_path(conn, :index))
    end
  end

  def update(conn, %{"id" => id, "product_brand" => params}) do
    with %ProductBrandSchema{} = brand <- ProductBrandModel.get(id),
         {:ok, _} <- ProductBrandModel.update(brand, params) do
      conn
      |> put_flash(:info, "Product Brand update successfully")
      |> redirect(to: product_brand_path(conn, :index))
    else
      {:error, changeset} ->
        render(conn, "edit.html", changeset: %{changeset | action: :edit})

      nil ->
        conn
        |> put_flash(:info, "Product Brand not found")
        |> redirect(to: product_brand_path(conn, :index))
    end
  end

  def delete(conn, %{"id" => id}) do
    case ProductBrandModel.delete(id) do
      {:ok, brand} ->
        conn
        |> put_flash(:info, "Product Brand #{brand.name} deleted successfully")
        |> redirect(to: product_brand_path(conn, :index))

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Failed to delete Product Brand")
        |> redirect(to: product_brand_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Cannot delete as products are associated")
        |> redirect(to: product_brand_path(conn, :index))
    end
  end
end
