defmodule AdminAppWeb.TaxCategoryController do
  use AdminAppWeb, :controller

  alias Snitch.Data.Model.TaxCategory, as: TaxCategoryModel
  alias Snitch.Data.Schema.TaxCategory

  def index(conn, _params) do
    tax_categories = TaxCategoryModel.get_all()
    render(conn, "index.html", tax_categories: tax_categories)
  end

  def create(conn, %{"tax_category" => tax_category}) do
    case TaxCategoryModel.create(tax_category) do
      {:ok, _} ->
        tax_categories = TaxCategoryModel.get_all()
        render(conn, "index.html", tax_categories: tax_categories)

      {:error, changeset} ->
        changeset = %{changeset | action: :insert}
        render(conn, "new.html", changeset: changeset)
    end
  end

  def new(conn, _params) do
    changeset = TaxCategory.create_changeset(%TaxCategory{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def edit(conn, %{"id" => id}) do
    id = String.to_integer(id)

    with tax_category when not is_nil(tax_category) <- TaxCategoryModel.get(id, true) do
      changeset = TaxCategory.update_changeset(tax_category, %{})

      render(conn, "edit.html",
        changeset: changeset,
        tax_category: tax_category
      )
    else
      nil ->
        conn
        |> put_flash(:error, "not found")
        |> redirect(to: tax_category_path(conn, :index))
    end
  end

  def update(conn, %{"id" => id, "tax_category" => params}) do
    tax_category =
      id
      |> String.to_integer()
      |> TaxCategoryModel.get(true)

    with {:ok, _category} <- TaxCategoryModel.update(params, tax_category) do
      conn
      |> put_flash(:info, "Tax category updated!")
      |> redirect(to: tax_category_path(conn, :index))
    else
      {:error, changeset} ->
        conn
        |> put_flash(:error, "There were some errors!")
        |> render("edit.html", changeset: changeset, tax_category: tax_category)
    end
  end

  def delete(conn, %{"id" => id}) do
    conn =
      with {:ok, _} <-
             id
             |> String.to_integer()
             |> TaxCategoryModel.delete() do
        put_flash(conn, :info, "tax category deleted")
      else
        {:error, %Ecto.Changeset{}} ->
          put_flash(conn, :error, "some error occured!")

        {:error, message} ->
          put_flash(conn, :error, message)
      end

    redirect(conn, to: tax_category_path(conn, :index))
  end
end
