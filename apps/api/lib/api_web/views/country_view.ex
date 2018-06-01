defmodule ApiWeb.CountryView do
  use ApiWeb, :view
  alias ApiWeb.StateView

  def render("country.json", %{country: country}) do
    country
    |> Map.from_struct()
    |> Map.drop(~w[__meta__ states]a)
  end

  def render("countries.json", %{countries: countries}) do
    render_many(countries, __MODULE__, "country.json")
  end
end
