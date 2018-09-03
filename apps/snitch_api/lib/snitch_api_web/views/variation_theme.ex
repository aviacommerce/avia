defmodule SnitchApiWeb.VariationThemeView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  alias SnitchApiWeb.OptionTypeView

  attributes([
    :name
  ])

  has_many(
    :option_types,
    serializer: OptionTypeView,
    include: false
  )
end
