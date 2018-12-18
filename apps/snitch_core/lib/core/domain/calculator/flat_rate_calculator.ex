defmodule Snitch.Domain.Calculator.FlatRate do
  @moduledoc """
  Models the `flate rate calculator`, exposes functionality related to
  it.
  """
  use Snitch.Data.Schema

  @behaviour Snitch.Domain.Calculator

  @type t :: %__MODULE__{}

  embedded_schema do
    field(:amount, :decimal, default: 0)
  end

  def changeset(%__MODULE__{} = data, params) do
    data
    |> cast(params, [:amount])
    |> validate_required([:amount])
  end

  # TODO implement the function
  def compute(item, amount) do
  end
end
