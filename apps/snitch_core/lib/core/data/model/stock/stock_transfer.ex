defmodule Snitch.Data.Model.StockTransfer do
  @moduledoc """
  StockTransfer CRUD API
  """

  use Snitch.Data.Model
  alias Snitch.Data.Schema.StockTransfer, as: StockTransferSchema

  @spec create(String.t(), String.t(), non_neg_integer, non_neg_integer) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def create(reference, number, source_id, destination_id) do
    QH.create(
      StockTransferSchema,
      %{
        reference: reference,
        number: number,
        source_id: source_id,
        destination_id: destination_id
      },
      Repo
    )
  end

  @spec get(non_neg_integer | map) :: {:ok, StockTransferSchema.t()} | {:error, atom}
  def get(query_fields), do: QH.get(StockTransferSchema, query_fields, Repo)

  @doc """
  Fetches all the transfers from DB.
  """
  @spec get_all :: list(StockTransferSchema.t())
  def get_all, do: Repo.all(StockTransferSchema)
end
