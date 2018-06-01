defmodule ApiWeb.StateView do
  use ApiWeb, :view

  def render("state.json", %{state: state}) do
    state
    |> Map.from_struct()
    |> Map.drop(~w[__meta__ country]a)
    |> Map.put(:abbr, state.code)
  end

  def render("states.json", %{states: states}) do
    %{states: render_many(states, __MODULE__, "state.json")}
  end
end
