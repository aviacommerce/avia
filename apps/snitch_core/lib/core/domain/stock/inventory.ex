defmodule Snitch.Domain.Inventory do
  @moduledoc """
  Interface for handling inventory related business logic
  """

  alias Snitch.Data.Model.StockItem, as: StockModel
  alias Snitch.Data.Model.StockLocation, as: SLModel
  alias Snitch.Data.Schema.StockItem, as: StockSchema
  alias Snitch.Data.Schema.Product
  alias Snitch.Data.Model.Product, as: ProductModel
  alias Snitch.Core.Tools.MultiTenancy.Repo

  use Snitch.Domain

  @doc """
  Updates the stock with stock fields passed for a product

  If the stock item is not present for a particular product and stock location,
  it created and then updated with the stock item params.
  """
  @spec add_stock(Product.t(), map) :: {:ok, StockSchema.t()} | {:error, Ecto.Changeset.t()}
  def add_stock(product, stock_params) do
    with {:ok, stock} <- check_stock(product.id, stock_params["stock_location_id"]),
         {:ok, updated_stock} <- StockModel.update(stock_params, stock) do
      {:ok, updated_stock}
    end
  end

  @doc """
  Reduces stock for a product at particular stock location by the amount passed.
  """
  def reduce_stock(product_id, stock_location_id, reduce_count) do
    with product <- ProductModel.get(product_id),
         stock_location <- SLModel.get(stock_location_id),
         {:ok, stock_item} <- check_stock(product.id, stock_location.id) do
      do_reduce_stock(stock_item, reduce_count, product.inventory_tracking)
    end
  end

  defp do_reduce_stock(stock_item, _, :none), do: {:ok, stock_item}

  defp do_reduce_stock(stock_item, reduce_count, inventory_tracking) do
    new_stock_count = stock_item.count_on_hand - reduce_count
    StockModel.update(%{count_on_hand: new_stock_count}, stock_item)
  end

  def set_inventory_tracking(product, inventory_tracking, %{"stock" => stock_params})
      when inventory_tracking in ["product", :product] do
    {:ok, stock_item} = check_stock(product.id, stock_params["stock_location_id"])

    Ecto.Multi.new()
    |> Ecto.Multi.run(:inventory_tracking, fn _ ->
      ProductModel.update(product, %{inventory_tracking: inventory_tracking})
    end)
    |> Ecto.Multi.run(:stock, fn _ -> StockModel.update(stock_params, stock_item) end)
    |> Repo.transaction()
    |> case do
      {:ok, multi_result} ->
        {:ok, multi_result.inventory_tracking}

      {:error, _, error, _} ->
        {:error, error}
    end
  end

  def set_inventory_tracking(product, inventory_tracking, _params) do
    ProductModel.update(product, %{inventory_tracking: inventory_tracking})
  end

  defp check_stock(product_id, location_id) do
    query_fields = %{product_id: product_id, stock_location_id: location_id}

    case StockModel.get(query_fields) do
      %StockSchema{} = stock_item -> {:ok, stock_item}
      nil -> StockModel.create(product_id, location_id, 0, false)
    end
  end
end
