defmodule SnitchApiWeb.ProductOptionValueView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  alias SnitchApiWeb.OptionTypeView

  attributes([
    :display_name,
    :value,
    :option_type_id
  ])

  has_one(
    :option_type,
    serializer: OptionTypeView,
    include: false
  )
end
