defmodule SnitchApiWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.
  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use SnitchApiWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(SnitchApiWeb.ChangesetView, "error.json", changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(SnitchApiWeb.ErrorView, :"404")
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:not_found)
    |> render(SnitchApiWeb.ErrorView, :unauthorized)
  end

  def call(conn, {:error, :no_credentials}) do
    conn
    |> put_status(:not_found)
    |> render(SnitchApiWeb.ErrorView, :no_credentials)
  end

  def call(conn, {:error, %{message: message}}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(SnitchApiWeb.ChangesetView, "error.json", message: message)
  end
end
