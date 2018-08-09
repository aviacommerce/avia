defmodule SnitchApiWeb.VariationThemeView do
  use SnitchApiWeb, :view
  use JaSerializer.PhoenixView

  alias SnitchApiWeb.OptionTypeView

  attributes([
    :weight
  ])

  has_many(
    :option_types,
    serializer: OptionTypeView,
    include: true
  )
end
