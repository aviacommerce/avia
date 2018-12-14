defmodule Snitch.Data.Schema.Adjustment do
  @moduledoc """
  Models a generic `adjustment` to keep a track of adjustments
  made against any entity.

  Adjustments can be made against entities such as an `order` or
  `lineitem` due to various reasons such as adding a promotion, or adding
  taxes etc.
  The adjustments table has a polymorphic relationship with the actions leading
  to it.
  """
end
