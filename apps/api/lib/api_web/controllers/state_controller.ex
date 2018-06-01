defmodule ApiWeb.StateController do
  use ApiWeb, :controller

  alias Snitch.Repo
  alias Snitch.Data.Schema.State
  alias ApiWeb.FallbackController, as: Fallback

  import Ecto.Query, only: [from: 2]

  def index(conn, %{"country_id" => country_id}) do
    states = Repo.all(from(s in State, where: s.country_id == ^country_id))
    render(conn, "states.json", states: states)
  end

  def show(conn, %{"id" => id, "country_id" => country_id}) do
    query = from(s in State, where: s.id == ^id and s.country_id == ^country_id)

    case Repo.one(query) do
      nil ->
        Fallback.call(conn, {:error, :not_found})

      %State{} = state ->
        render(conn, "state.json", state: state)
    end
  end
end
