defmodule AdminAppWeb.ErrorView do
  use AdminAppWeb, :view

  def render("500.html", _assigns) do
    "Internal server error"
  end

  def render("401.json", _assigns) do
    %{
      error: %{
        message: "data not found"
      }
    }
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render("500.html", assigns)
  end
end
