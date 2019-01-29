defmodule Snitch.Data.Model.ProductOptionValue do
  @moduledoc """
  Product Option Value API.
  """

  use Snitch.Data.Model

  alias Snitch.Data.Schema.ProductOptionValue

  @doc """
  Update the Option Value with supplied params and Option Value instance
  """
  @spec update(ProductOptionValue.t(), map) ::
          {:ok, ProductOptionValue.t()} | {:error, Ecto.Changeset.t()}
  def update(model, params) do
    QH.update(ProductOptionValue, params, model, Repo)
  end

  @doc """
  Returns an Product Option Value

  Takes Product Option Value id as input
  """
  @spec get(integer) :: {:ok, ProductOptionValue.t()} | {:error, atom}
  def get(id) do
    QH.get(ProductOptionValue, id, Repo)
  end
end
