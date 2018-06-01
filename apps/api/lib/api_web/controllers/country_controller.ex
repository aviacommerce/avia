defmodule ApiWeb.CountryController do
  use ApiWeb, :controller

  alias Snitch.Repo
  alias Snitch.Data.Schema.Country
  alias ApiWeb.FallbackController, as: Fallback

  import Ecto.Query, only: [from: 2]

  def index(conn, _params) do
    countries = Repo.all(Country)
    render(conn, "countries.json", countries: countries)
  end

  def show(conn, %{"id" => id}) do
    query = from(c in Country, where: c.id == ^id)

    case Repo.one(query) do
      nil ->
        Fallback.call(conn, {:error, :not_found})

      country ->
        render(conn, "country.json", country: country)
    end
  end
end
