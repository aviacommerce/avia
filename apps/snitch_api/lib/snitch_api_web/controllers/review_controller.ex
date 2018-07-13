defmodule SnitchApiWeb.ReviewController do
  use SnitchApiWeb, :controller

  alias SnitchApi.Review

  plug(SnitchApiWeb.Plug.DataToAttributes)

  action_fallback(SnitchApiWeb.FallbackController)

  def create(conn, params) do
    with {:ok, review} <- Review.create(params) do
      conn
      |> put_status(:created)
      |> render("show.json-api", data: review)
    end
  end

  def update(conn, %{"id" => id} = params) do
    with {:ok, review} <- Review.update(id, params) do
      render(conn, "show.json-api", data: review)
    end
  end

  def delete(conn, params) do
    with {:ok, _} <- Review.delete(params) do
      send_resp(conn, :no_content, "")
    end
  end
end
