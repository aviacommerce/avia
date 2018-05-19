defmodule Snitch.Domain.StockLocation do
  @moduledoc """
  Interface for handling stock location related business logic
  """

  use Snitch.Domain
  alias Model.StockLocation, as: StockLocationModel

  def search(params \\ %{}) do
    StockLocationModel.search(params)
  end
end
