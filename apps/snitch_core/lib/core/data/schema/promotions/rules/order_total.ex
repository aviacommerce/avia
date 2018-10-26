defmodule Snitch.Data.Schema.PrmotionRule.OrderTotal do
  @moduledoc false

  use Snitch.Data.Schema

  embedded_schema do
    field(:lower_range, :decimal, default: 0.0)
    field(:upper_range, :decimal, default: 0.0)
  end

  def changeset(%__MODULE__{} = data, params) do
    data
    |> cast(params, [:lower_range, :upper_range])
  end
end
