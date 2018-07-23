defmodule SnitchApiWeb.LineItemController do
  use SnitchApiWeb, :controller

  alias Snitch.Data.Model.LineItem, as: LineItemModel
  alias Snitch.Data.Schema.LineItem
  alias Snitch.Data.Schema.Variant
  alias Snitch.Repo

  plug(SnitchApiWeb.Plug.DataToAttributes)
  plug(SnitchApiWeb.Plug.LoadUser)

  def create(conn, %{"variant_id" => variant_id} = params) do
    %{cost_price: cost_price} = Repo.get(Variant, variant_id)
    line_item = Map.put(params, "unit_price", cost_price)

    with {:ok, line_item} <- LineItemModel.create(line_item) do
      conn
      |> put_status(200)
      |> put_resp_header("location", line_item_path(conn, :show, line_item.id))
      |> render("show.json-api", data: line_item)
    end
  end

  def update(conn, %{"id" => id} = params) do
    line_item = Repo.get(LineItem, id)

    with {:ok, line_item} <- LineItemModel.update(line_item, params) do
      conn
      |> put_status(200)
      |> put_resp_header("location", line_item_path(conn, :show, line_item))
      |> render("show.json-api", data: line_item)
    end
  end

  def show(conn, %{"id" => id}) do
    case LineItemModel.get(id) do
      nil ->
        conn
        |> put_status(204)
        |> render("show.json-api", data: [])

      line_item ->
        conn
        |> put_status(200)
        |> render("show.json-api", data: line_item)
    end
  end
end
