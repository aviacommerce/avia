defmodule AdminAppWeb.OptionTypeController do
  use AdminAppWeb, :controller
  alias Snitch.Data.Model.OptionType, as: OTModel
  alias Snitch.Data.Schema.OptionType, as: OTSchema

  def index(conn, _params) do
    option_types = OTModel.get_all()
    render(conn, "index.html", %{option_types: option_types})
  end

  def new(conn, _params) do
    changeset = OTSchema.create_changeset(%OTSchema{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"option_type" => params}) do
    case OTModel.create(params) do
      {:ok, _} ->
        option_types = OTModel.get_all()
        render(conn, "index.html", %{option_types: option_types})

      {:error, changeset} ->
        render(conn, "new.html", changeset: %{changeset | action: :new})
    end
  end

  def edit(conn, %{"id" => id}) do
    with {id, _} <- Integer.parse(id),
         %OTSchema{} = option_type <- OTModel.get(id) do
      changeset = OTSchema.update_changeset(option_type, %{})
      render(conn, "edit.html", changeset: changeset)
    else
      :error ->
        conn
        |> put_flash(:info, "Invalid id #{id}")
        |> redirect(to: option_type_path(conn, :index))

      nil ->
        conn
        |> put_flash(:info, "No resource found")
        |> redirect(to: option_type_path(conn, :index))
    end
  end

  def update(conn, %{"id" => id, "option_type" => params}) do
    with {id, _} <- Integer.parse(id),
         option_type <- OTModel.get(id),
         _ <- OTModel.update(option_type, params) do
      option_types = OTModel.get_all()
      render(conn, "index.html", %{option_types: option_types})
    else
      {:error, changeset} ->
        render(conn, "edit.html", changeset: %{changeset | action: :edit})

      :error ->
        conn
        |> halt()
        |> put_flash(:info, "Invalid id #{id}")
        |> redirect(to: option_type_path(conn, :index))
    end
  end

  def delete(conn, %{"id" => id}) do
    with {id, _} <- Integer.parse(id),
         {:ok, option_type} <- OTModel.delete(id) do
      conn
      |> put_flash(:info, "Option type #{option_type.name} deleted successfully")
      |> redirect(to: option_type_path(conn, :index))
    else
      {:error, _} ->
        conn
        |> put_flash(:error, "Failed to delete option type")
        |> redirect(to: option_type_path(conn, :index))

      :error ->
        conn
        |> halt()
        |> put_flash(:info, "Invalid id #{id}")
        |> redirect(to: option_type_path(conn, :index))
    end
  end
end
