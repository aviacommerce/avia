defmodule SnitchApiWeb.AddressView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  attributes([
    :id,
    :address_line_1,
    :address_line_2,
    :alternate_phone,
    :city,
    :first_name,
    :last_name,
    :phone,
    :state_id,
    :zip_code
  ])
end
