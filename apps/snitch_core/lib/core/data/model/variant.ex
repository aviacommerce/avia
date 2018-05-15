defmodule Snitch.Data.Model.Variant do
  @moduledoc """
  Variant API
  """
  use Snitch.Data.Model
  alias Snitch.Data.Schema.Variant

  def get_category(%Variant{}) do
    %{id: 0}
  end
end
