defmodule SnitchApiWeb.AddressView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  alias SnitchApiWeb.AddressView

  location("/addresses/:id")

  attributes([
    :first_name,
    :last_name,
    :address_line_1,
    :address_line_2,
    :city,
    :phone,
    :alternate_phone,
    :zip_code,
    :state_id,
    :country_id
  ])

  def render("address.json-api", %{data: address}) do
    %{
      id: address.id,
      address_line_1: address.address_line_1,
      address_line_2: address.address_line_2,
      first_name: address.first_name,
      last_name: address.last_name,
      city: address.city,
      zip_code: address.zip_code,
      phone: address.phone,
      alternate_phone: address.alternate_phone,
      state_id: address.state_id,
      country_id: address.country_id
    }
  end
end

defmodule SnitchApiWeb.CountryView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  location("/countries/:id")

  attributes([
    :name,
    :iso_name
  ])

  has_many(
    :states,
    serializer: SnitchApiWeb.StateView,
    include: false
  )
end

defmodule SnitchApiWeb.StateView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  attributes([
    :name,
    :code
  ])
end
