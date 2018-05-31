defmodule ApiWeb.AddressView do
  use ApiWeb, :view

  def render("address.json", %{address: address}) do
    %{
      firstname: address.first_name,
      lastname: address.last_name,
      address1: address.address_line_1,
      address2: address.address_line_2,
      zipcode: address.zip_code,
      city: address.city,
      phone: address.phone,
      state_id: address.state_id,
      country_id: address.country_id
    }
  end
end
