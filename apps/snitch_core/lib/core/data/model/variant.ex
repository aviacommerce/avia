defmodule Snitch.Data.Model.Variant do
  @moduledoc """
  Variant API
  """
  use Snitch.Data.Model
  alias Snitch.Data.Schema.Variant

  def get_category(%Variant{} = v) do
    variant = Repo.preload(v, :shipping_category)
    variant.shipping_category
  end
end
