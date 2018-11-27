defmodule AdminAppWeb.GeneralSettingsView do
  use AdminAppWeb, :view
  alias Snitch.Data.Model.ProductBrand

  @currencies ["USD", "INR", "GDP", "EUR"]

  def get_image_url(image, general_settings) do
    ProductBrand.image_url(image.name, general_settings)
  end

  def get_currency() do
    @currencies
  end
end
