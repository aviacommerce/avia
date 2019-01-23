defmodule Snitch.Data.Model.TaxConfig do
  @moduledoc """
  Module exposes functions to handle Tax Confiugration.

  The tax configuration has been handled using `single row`
  modelling. The initial row is created via seed and it can
  only be updated no create new or delete actions.
  """

  use Snitch.Data.Model
  alias Snitch.Data.Schema.TaxConfig

  @spec update(TaxConfig.t(), map) ::
          {:ok, TaxConfig.t()}
          | {:error, Ecto.Changeset.t()}
  def update(tax_configuration, params) do
    QH.update(TaxConfig, params, tax_configuration, Repo)
  end

  @doc """
  Gets the tax configuration by the supplied id.
  """
  @spec get(non_neg_integer) :: {:ok, TaxConfig.t()} | {:error, atom}
  def get(id) do
    QH.get(TaxConfig, id, Repo)
  end
end
