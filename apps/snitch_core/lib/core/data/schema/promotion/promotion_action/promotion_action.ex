defmodule Snitch.Data.Schema.PromotionAction do
  @moduledoc """
  Models the `actions` to be activated if for a `promotion`.

  The actions are after effects of `promotion` application and
  create adjustments for the payload depending on the type of action.

  An action of type `free shipping` will remove the shipping cost for
  the order whereas a discount action will provide some adjustment on the
  total order price.

  An action can be on the entire order or individual lineitem depending on
  the type of action.
  """
end
