defmodule ApiWeb.CheckoutView do
  use ApiWeb, :view
  alias ApiWeb.PackageView

  def render("packages.json", %{packages: packages}) do
    render_many(packages, PackageView, "package.json")
  end
end
