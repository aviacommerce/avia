defmodule AdminAppWeb.ProductBrandView do
  use AdminAppWeb, :view
  alias Snitch.Data.Model.Image

  def get_image_url(image, product_brand) do
    Image.image_url(image.name, product_brand)
  end
end
