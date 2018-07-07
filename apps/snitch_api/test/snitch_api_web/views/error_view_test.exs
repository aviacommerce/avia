defmodule SnitchApiWeb.ErrorViewTest do
  use SnitchApiWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.json-api" do
    assert render(SnitchApiWeb.ErrorView, "404.json-api", []) ==
             %{errors: %{detail: "Page not found"}}
  end

  test "render 500.json-api" do
    assert render(SnitchApiWeb.ErrorView, "500.json-api", []) ==
             %{errors: %{detail: "Internal server error"}}
  end

  test "render any other" do
    assert render(SnitchApiWeb.ErrorView, "505.json-api", []) ==
             %{errors: %{detail: "Internal server error"}}
  end
end
