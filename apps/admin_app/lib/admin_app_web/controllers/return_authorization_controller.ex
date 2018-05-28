defmodule AdminAppWeb.ReturnAuthorizationController do
  use AdminAppWeb, :controller

  alias Snitch.Data.Model.ReturnAuthorization, as: RAModel
  alias Snitch.Data.Schema.ReturnAuthorization, as: RASchema
  alias Snitch.Repo

  def index(conn, _params) do
    return_authorizations =
      RAModel.get_all() |>
      Repo.preload(:order)
    render(conn, "index.html", return_authorizations: return_authorizations)
  end

  def show(conn, %{"id" => number}) do
    return_auth =
      %{number: number}
      |> RAModel.get()
      |> Repo.preload(order: [line_items: [variant: :product]])
    
    changeset = RASchema.update_changeset(return_auth, %{})

    render(conn, "show.html", return_auth: return_auth, changeset: changeset)
  end
end
