defmodule AdminAppWeb.PrototypeController do
  use AdminAppWeb, :controller

  alias Snitch.Data.Schema.ProductPrototype, as: PrototypeSchema
  alias Snitch.Data.Model.ProductPrototype, as: PrototypeModel
  alias Snitch.Data.Model.{Property, VariationTheme}
  alias Snitch.Domain.Taxonomy

  plug(:load_resources when action in [:new, :edit, :update, :create])

  def index(conn, _params) do
    prototypes = PrototypeModel.get_all()
    render(conn, "index.html", prototypes: prototypes)
  end

  def new(conn, _params) do
    changeset = PrototypeSchema.create_changeset(%PrototypeSchema{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"product_prototype" => params}) do
    case PrototypeModel.create(params) do
      {:ok, _} ->
        prototypes = PrototypeModel.get_all()
        render(conn, "index.html", prototypes: prototypes)

      {:error, changeset} ->
        render(conn, "new.html", changeset: %{changeset | action: :new})
    end
  end

  def edit(conn, %{"id" => id}) do
    case PrototypeModel.get(id) do
      {:ok, %PrototypeSchema{} = prototype} ->
        changeset = PrototypeSchema.update_changeset(prototype, %{})
        render(conn, "edit.html", changeset: changeset)

      {:error, _} ->
        conn
        |> put_flash(:info, "Prototype not found")
        |> redirect(to: prototype_path(conn, :index))
    end
  end

  def update(conn, %{"id" => id, "product_prototype" => params}) do
    with {:ok, %PrototypeSchema{} = prototype} <- PrototypeModel.get(id),
         {:ok, _} <- PrototypeModel.update(prototype, params) do
      prototypes = PrototypeModel.get_all()
      render(conn, "index.html", prototypes: prototypes)
    else
      {:error, :product_prototype_not_found} ->
        conn
        |> put_flash(:info, "Prototype not found")
        |> redirect(to: prototype_path(conn, :index))

      {:error, changeset} ->
        render(conn, "edit.html", changeset: %{changeset | action: :edit})
    end
  end

  def delete(conn, %{"id" => id}) do
    case PrototypeModel.delete(id) do
      {:ok, prototype} ->
        conn
        |> put_flash(:info, "Product prototype #{prototype.name} deleted successfully")
        |> redirect(to: prototype_path(conn, :index))

      {:error, _} ->
        conn
        |> put_flash(:error, "Failed to delete Product Protoype")
        |> redirect(to: variation_theme_path(conn, :index))
    end
  end

  defp load_resources(conn, _opts) do
    themes = VariationTheme.get_all()
    properties = Property.get_all()

    leaf_taxons =
      "Pets"
      |> Taxonomy.get_taxonomy()
      |> Taxonomy.get_leaves()

    conn
    |> assign(:themes, themes)
    |> assign(:properties, properties)
    |> assign(:taxons, leaf_taxons)
  end
end
