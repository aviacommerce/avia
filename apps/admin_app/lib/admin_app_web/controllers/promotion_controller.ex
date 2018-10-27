defmodule AdminAppWeb.PromotionController do
  use AdminAppWeb, :controller

  alias Snitch.Data.Model
  alias Snitch.Data.Schema
  alias Snitch.Core.Tools.MultiTenancy.Repo
  # alias AdminAppWeb.Helpers

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def new(conn, _params) do
    changeset = Schema.Promotion.create_changeset(%Schema.Promotion{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, params) do
    # updated_params = get_date_from_params(params["promotion"])
    changeset = Schema.Promotion.create_changeset(%Schema.Promotion{}, params["promotion"])

    render(conn, "new.html", changeset: changeset)


    # create_params = params |> add_members_params
    # zone_changeset = ZoneSchema.create_changeset(%ZoneSchema{}, create_params)
    # zone_multi = Zone.creation_multi(zone_changeset, create_params["members"])

    # case Repo.transaction(zone_multi, []) do
    #   {:ok, _response} ->
    #     conn
    #     |> put_flash(:info, "Zone created!!")
    #     |> redirect(to: zone_path(conn, :index))

    #   {:error, _, changset, _} ->
    #     conn
    #     |> put_flash(:error, "Sorry there were some errors !!")
    #     |> render("new.html", changeset: changset)
    # end
  end

  def edit(conn, %{"id" => id}) do
    # case Zone.get(id) do
    #   %ZoneSchema{} = zone ->
    #     members = zone |> Zone.members() |> Enum.into([], fn x -> x.id end)
    #     changeset = ZoneSchema.update_changeset(zone, %{members: members})

    #     render(conn, "edit.html", changeset: changeset, id: id, zone: zone)

    #   nil ->
    #     conn
    #     |> put_flash(:info, "Zone not found")
    #     |> redirect(to: zone_path(conn, :index))
    # end
  end

  def update(conn, params) do
    # with %ZoneSchema{} = zone <- Zone.get(params["id"]),
    #      zone_changeset <-
    #        ZoneSchema.update_changeset(
    #          zone,
    #          params["zone"]
    #        ),
    #      {:ok, _response} <-
    #        Zone.update_multi(zone, zone_changeset, zone |> member_list_from_params(params))
    #        |> Repo.transaction() do
    #   conn
    #   |> put_flash(:info, "Zone updated!!")
    #   |> redirect(to: zone_path(conn, :index))
    # else
    #   {:error, _, changeset, _} ->
    #     conn
    #     |> put_flash(:error, "Sorry there were some errors !!")
    #     |> render("edit.html", changeset: changeset, id: params["id"])

    #   nil ->
    #     conn
    #     |> put_flash(:info, "Zone not found")
    #     |> redirect(to: zone_path(conn, :index))
    # end
  end

  def delete(conn, %{"id" => id}) do
    # id = String.to_integer(id)

    # case Zone.delete(id) do
    #   {:ok, _} ->
    #     conn
    #     |> put_flash(:info, "Deleted successfully!!")
    #     |> redirect(to: zone_path(conn, :index))

    #   {:error, _} ->
    #     conn
    #     |> put_flash(:error, "not found")
    #     |> redirect(to: zone_path(conn, :index))
    # end
  end

  defp get_naive_date_time(date) do
    Date.from_iso8601(date)
    |> elem(1)
    |> NaiveDateTime.new(~T[00:00:00])
    |> elem(1)
  end

  defp get_date_from_params(params) do
    # start_date = Helpers.get_date_from_params(params, "starts_at") |> get_naive_date_time()
    # end_date = Helpers.get_date_from_params(params, "expires_at") |> get_naive_date_time()

    # params |> Map.put("starts_at", start_date) |> Map.put("expires_at", end_date)
  end
end
