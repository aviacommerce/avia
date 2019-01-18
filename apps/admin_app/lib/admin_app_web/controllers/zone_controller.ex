defmodule AdminAppWeb.ZoneController do
  use AdminAppWeb, :controller

  alias Snitch.Data.Model.Zone
  alias Snitch.Data.Schema.Zone, as: ZoneSchema
  alias Snitch.Core.Tools.MultiTenancy.Repo

  def index(conn, _params) do
    zones = Zone.get_all()
    render(conn, "index.html", zones: zones)
  end

  def new(conn, _params) do
    changeset = ZoneSchema.create_changeset(%ZoneSchema{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, params) do
    create_params = params |> add_members_params
    zone_changeset = ZoneSchema.create_changeset(%ZoneSchema{}, create_params)
    zone_multi = Zone.creation_multi(zone_changeset, create_params["members"])

    case Repo.transaction(zone_multi, []) do
      {:ok, _response} ->
        conn
        |> put_flash(:info, "Zone created!!")
        |> redirect(to: zone_path(conn, :index))

      {:error, _, changset, _} ->
        conn
        |> put_flash(:error, "Sorry there were some errors !!")
        |> render("new.html", changeset: changset)
    end
  end

  def edit(conn, %{"id" => id}) do
    case Zone.get(id) do
      %ZoneSchema{} = zone ->
        members = zone |> Zone.members() |> Enum.into([], fn x -> x.id end)
        changeset = ZoneSchema.update_changeset(zone, %{members: members})

        render(conn, "edit.html", changeset: changeset, id: id, zone: zone)

      nil ->
        conn
        |> put_flash(:info, "Zone not found")
        |> redirect(to: zone_path(conn, :index))
    end
  end

  def update(conn, params) do
    with %ZoneSchema{} = zone <- Zone.get(params["id"]),
         zone_changeset <-
           ZoneSchema.update_changeset(
             zone,
             params["zone"]
           ),
         {:ok, _response} <-
           Zone.update_multi(zone, zone_changeset, zone |> member_list_from_params(params))
           |> Repo.transaction() do
      conn
      |> put_flash(:info, "Zone updated!!")
      |> redirect(to: zone_path(conn, :index))
    else
      nil ->
        conn
        |> put_flash(:info, "Zone not found")
        |> redirect(to: zone_path(conn, :index))

      {:error, _, changeset, _} ->
        conn
        |> put_flash(:error, "Sorry there were some errors !!")
        |> render("edit.html", changeset: changeset, id: params["id"])
    end
  end

  def delete(conn, %{"id" => id}) do
    id = String.to_integer(id)

    case Zone.delete(id) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Deleted successfully!!")
        |> redirect(to: zone_path(conn, :index))

      {:error, _} ->
        conn
        |> put_flash(:error, "not found")
        |> redirect(to: zone_path(conn, :index))
    end
  end

  defp add_members_params(params) do
    case params["zone"]["zone_type"] do
      "C" -> params["zone"] |> Map.put("members", params["zone"]["country_members"] || [])
      "S" -> params["zone"] |> Map.put("members", params["zone"]["state_members"] || [])
      nil -> []
    end
  end

  defp member_list_from_params(zone, params) do
    case zone.zone_type do
      "C" -> params["zone"]["country_members"]
      "S" -> params["zone"]["state_members"]
    end
  end
end
