defmodule AdminAppWeb.Tax.TaxClassController do
  use AdminAppWeb, :controller
  import Phoenix.View, only: [render_to_string: 3]
  alias Snitch.Data.Model.TaxClass
  alias Snitch.Data.Schema.TaxClass, as: TaxClassSchema

  plug(:put_layout, {AdminAppWeb.Tax.TaxConfigView, "tax_layout.html"})

  def index(conn, _params) do
    tax_classes = TaxClass.get_all()

    render(conn, "index.html", tax_classes: tax_classes)
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, _data} <- id |> String.to_integer() |> TaxClass.delete() do
      conn
      |> put_flash(:info, "tax class deleted")
      |> redirect(to: tax_class_path(conn, :index))
    else
      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> redirect(to: tax_class_path(conn, :index))
    end
  end

  def new(conn, _params) do
    changeset = TaxClassSchema.create_changeset(%TaxClassSchema{}, %{})

    html =
      render_to_string(
        AdminAppWeb.Tax.TaxClassView,
        "new.html",
        changeset: changeset,
        conn: conn
      )

    conn
    |> put_status(200)
    |> json(%{html: html})
  end

  def create(conn, %{"tax_class" => params}) do
    with {:ok, tax_class} <- TaxClass.create(params) do
      html =
        render_to_string(
          AdminAppWeb.Tax.TaxClassView,
          "_tax_class.html",
          conn: conn,
          tax_class: tax_class
        )

      conn
      |> put_status(200)
      |> json(%{html: html})
    else
      {:error, changeset} ->
        html =
          render_to_string(
            AdminAppWeb.Tax.TaxClassView,
            "new.html",
            changeset: %{changeset | action: :insert},
            conn: conn
          )

        conn
        |> put_status(422)
        |> json(%{html: html})
    end
  end

  def edit(conn, %{"id" => id}) do
    with {:ok, tax_class} <- TaxClass.get(id) do
      changeset = TaxClassSchema.update_changeset(tax_class, %{})

      html =
        render_to_string(
          AdminAppWeb.Tax.TaxClassView,
          "edit.html",
          conn: conn,
          tax_class: tax_class,
          changeset: changeset
        )

      conn
      |> put_status(200)
      |> json(%{html: html})
    end
  end

  def update(conn, %{"id" => id, "tax_class" => params}) do
    {:ok, tax_class} = id |> String.to_integer() |> TaxClass.get()

    with {:ok, tax_class} <- TaxClass.update(tax_class, params) do
      html =
        render_to_string(
          AdminAppWeb.Tax.TaxClassView,
          "_tax_class.html",
          conn: conn,
          tax_class: tax_class
        )

      conn
      |> put_status(200)
      |> json(%{html: html})
    else
      {:error, changeset} ->
        html =
          render_to_string(
            AdminAppWeb.Tax.TaxClassView,
            "edit.html",
            changeset: %{changeset | action: :update},
            conn: conn,
            tax_class: tax_class
          )

        conn
        |> put_status(422)
        |> json(%{html: html})
    end
  end
end
