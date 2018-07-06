defmodule Snitch.Data.Model.Variant do
  @moduledoc """
  Variant API
  """
  use Snitch.Data.Model

  alias Snitch.Data.Schema.Variant

  def get_selling_prices(variant_ids) do
    # TODO: change the source of selling price to the something else.
    query = from(v in Variant, select: {v.id, v.selling_price}, where: v.id in ^variant_ids)

    query
    |> Repo.all()
    |> Enum.reduce(%{}, fn {v_id, sp}, acc ->
      Map.put(acc, v_id, sp)
    end)
  end
end
