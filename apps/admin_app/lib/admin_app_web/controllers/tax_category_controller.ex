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
    changeset = TaxCategory.changeset(%TaxCategory{})
    render(conn, "new.html", changeset: changeset)
  end
end
