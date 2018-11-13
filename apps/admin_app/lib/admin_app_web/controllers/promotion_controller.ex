defmodule AdminAppWeb.PromotionController do
  use AdminAppWeb, :controller

  alias Snitch.Data.Model
  alias Snitch.Data.Schema
  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias AdminAppWeb.Helpers
  alias AdminAppWeb.PromotionView

  def index(conn, _params) do
    promotions = Model.Promotion.get_all()
    render(conn, "index.html", promotions: promotions)
  end

  def new(conn, _params) do
    changeset = Schema.Promotion.create_changeset(%Schema.Promotion{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, params) do
    updated_params = get_date_from_params(params["promotion"])

    case Model.Promotion.create(updated_params) do
      {:ok, changeset} ->
        conn
        |> put_flash(:info, "Promotion created!!")
        |> redirect(to: promotion_path(conn, :edit, changeset.id))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Sorry there were some errors !!")
        |> render("new.html", changeset: changeset)
    end
  end

  def rule_create(conn, params) do
    rule_create_params =
      params["rules"] |> Map.put("module", params["rules"]["module"])

    with %Schema.Promotion{} = promotion <- Model.Promotion.get(params["id"]),
         {:ok, %Schema.Promotion{} = _promotion_with_rule} <-
           Model.Promotion.add_promo_rules(promotion, List.wrap(rule_create_params)) do
      conn
      |> put_flash(:info, "Promotion rule added!")
      |> redirect(to: promotion_path(conn, :index))
    else
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Sorry there were some errors !!")
        |> render("edit.html", changeset: changeset, id: params["id"])

      {:error, _, changeset, _} ->
        conn
        |> put_flash(:error, "Sorry there were some errors !!")
        |> render("edit.html", changeset: changeset, id: params["id"])

      nil ->
        conn
        |> put_flash(:info, "Promotion not found")
        |> redirect(to: promotion_path(conn, :index))
    end
  end

  def render_form(conn, params) do
    token = get_csrf_token()

    html =
      Phoenix.View.render_to_string(
        PromotionView,
        "input_form.html",
        conn: conn,
        data: params,
        token: token
      )

    conn
    |> put_status(200)
    |> json(%{html: html})
  end

  def edit(conn, %{"id" => id}) do
    case Model.Promotion.get(id) do
      %Schema.Promotion{} = promotion ->
        changeset = Schema.Promotion.update_changeset(promotion, %{})

        render(conn, "edit.html", changeset: changeset, id: id, promotion: promotion)

      nil ->
        conn
        |> put_flash(:info, "Promotion not found")
        |> redirect(to: promotion_path(conn, :index))
    end
  end

  def update(conn, params) do
    with %Schema.Promotion{} = promotion <- Model.Promotion.get(params["id"]),
         {:ok, %Schema.Promotion{} = _updated_promotion} <-
           Model.Promotion.add_promo_rules(promotion, params) do
      conn
      |> put_flash(:info, "Promotion updated!!")
      |> redirect(to: promotion_path(conn, :index))
    else
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Sorry there were some errors !!")
        |> render("edit.html", changeset: changeset, id: params["id"])

      # make available promotion here in above render
      nil ->
        conn
        |> put_flash(:info, "Zone not found")
        |> redirect(to: promotion_path(conn, :index))
    end
  end

  def delete(conn, %{"id" => id}) do
    id = String.to_integer(id)

    case Model.Promotion.delete(id) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Promotion deleted successfully!!")
        |> redirect(to: promotion_path(conn, :index))

      {:error, _} ->
        conn
        |> put_flash(:error, "Promotion not found")
        |> redirect(to: promotion_path(conn, :index))
    end
  end

  defp get_naive_date_time(date) do
    Date.from_iso8601(date)
    |> elem(1)
    |> NaiveDateTime.new(~T[00:00:00])
    |> elem(1)
  end

  defp get_date_from_params(params) do
    start_date = Helpers.get_date_from_params(params, "starts_at") |> get_naive_date_time()
    end_date = Helpers.get_date_from_params(params, "expires_at") |> get_naive_date_time()

    params |> Map.put("starts_at", start_date) |> Map.put("expires_at", end_date)
  end
end
