defmodule AdminAppWeb.ProductBrandView do
  use AdminAppWeb, :view
  alias Snitch.Data.Model.ProductBrand

  def get_image_url(image, product_brand) do
    ProductBrand.image_url(image.name, product_brand)
  end
end
