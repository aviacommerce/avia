defmodule Snitch.Data.Model.ShipmentUnit do
  @moduledoc """
  """

  use Snitch.Data.Model
  alias Snitch.Data.Schema.ShipmentUnit, as: ShipmentUnitSchema

  @spec create(String.t(), Boolean.t(), non_neg_integer, non_neg_integer) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def create(state, quantity, line_item_id, variant_id) do
    QH.create(
      ShipmentUnitSchema,
      %{
        state: state,
        quantity: quantity,
        line_item_id: line_item_id,
        variant_id: variant_id
      },
      Repo
    )
  end

  @spec get(non_neg_integer | map) :: ShipmentUnitSchema.t()
  def get(query_fields) do
    QH.get(ShipmentUnitSchema, query_fields, Repo)
  end

  @spec get_all :: list(ShipmentUnitSchema.t())
  def get_all, do: Repo.all(ShipmentUnitSchema)
end
