defmodule SnitchApiWeb.PromotionView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  def render("success.json-api", %{message: message}) do
    %{
      error: nil,
      message: message,
      status: "success"
    }
  end

  def render("error.json-api", %{message: message}) do
    %{
      error: true,
      message: message,
      status: "failed"
    }
  end
end
