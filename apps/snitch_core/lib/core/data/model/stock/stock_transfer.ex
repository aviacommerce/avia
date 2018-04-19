defmodule Snitch.Data.Model.StockTransfer do
  @moduledoc """
  """

  use Snitch.Data.Model
  alias Snitch.Data.Schema.StockItem, as: StockItemSchema
  alias Snitch.Data.Schema.StockTransfer, as: StockTransferSchema

  @spec create(String.t(), String.t(), non_neg_integer, non_neg_integer) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def create(reference, number, source_location_id, destination_location_id) do
    QH.create(
      StockTransferSchema,
      %{
        reference: reference,
        number: number,
        source_location_id: source_location_id,
        destination_location_id: destination_location_id
      },
      Repo
    )
  end

  @spec get(non_neg_integer | map) :: StockTransferSchema.t()
  def get(query_fields), do: QH.get(StockTransferSchema, query_fields, Repo)

  @doc """
  Fetches all the stock items present in the DB
  """
  @spec get_all :: list(StockTransferSchema.t())
  def get_all, do: Repo.all(StockTransferSchema)
end
