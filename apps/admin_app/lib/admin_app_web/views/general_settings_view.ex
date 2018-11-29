defmodule AdminAppWeb.GeneralSettingsView do
  use AdminAppWeb, :view
  alias Snitch.Data.Model.ProductBrand
  alias Snitch.Data.Model.GeneralConfiguration, as: GCModel

  def get_image_url(image, general_settings) do
    ProductBrand.image_url(image.name, general_settings)
  end

  def get_currency() do
    GCModel.get_currency_list()
  end
end
