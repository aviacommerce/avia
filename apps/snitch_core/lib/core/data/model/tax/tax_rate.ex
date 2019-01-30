defmodule Snitch.Data.Model.TaxRate do
  @moduledoc """
  Exposes APIs for tax rate CRUD.
  """

  use Snitch.Data.Model
  alias Snitch.Data.Schema.TaxRate

  @doc """
  Creates a tax rate for the supplied params.

  Expects the following keys in the `params`:
  - `*name`: Name of the tax rate.
  - `*tax_zone_id`: id of the tax zone for which tax rate would be created.
  - `is_active?`: a boolean value which represents if the tax rate would be treated
        as active or not, this is optional param and is set to true by default.
  - `priority`: The priority in which the taxes would be calculated. To see further
     details. See `Snitch.Data.Schema.TaxRate`.
  - `*tax_rate_class_values`: A set of values to be set for different tax classes. The values
      set are used to calculate the taxes for the order falling in the tax zone having the tax
      rate.
      The `tax_rate_class_values` is a map which expects the following keys:
      - `*tax_rate_class_id`: The class for which value would be stored for the tax rate.
      - `*percent_amount`: The amount to be stored for the `tax_class`.

      The `tax_rate_class_values` are being handled using
      `Ecto.Changeset.cast_assoc(changeset, name, opts \\ [])` with tax rate.

  > The tax rate names are unique for every tax zone.
  > Also, a tax rate can be associated with a class in the `tax_rate_class_values` table only once.
  > `*` are required params.

  """
  @spec create(map) :: {:ok, TaxRate.t()} | {:error, Ecto.Changeset.t()}
  def create(params) do
    QH.create(TaxRate, params, Repo)
  end

  @doc """
  Updates a `TaxRate` with the supplied `params`.

  To know about the expected keys see `create/1`

  > Since `:tax_rate_class_values` for a tax rate are updated with cast_assoc
    rules added by `Ecto.Changeset.cast_assoc/3` are applied.
  """
  @spec update(TaxRate.t(), map) :: {:ok, TaxRate.t()} | {:error, Ecto.Changeset.t()}
  def update(tax_rate, params) do
    tax_rate = tax_rate |> Repo.preload(tax_rate_class_values: :tax_class)
    QH.update(TaxRate, params, tax_rate, Repo)
  end

  @doc """
  Deletes a TaxRate.
  """
  def delete(id) do
    QH.delete(TaxRate, id, Repo)
  end

  @doc """
  Returns a tax rate preloaded with it's values corresponding to
  tax classes under the key `:tax_rate_class_values`
  """
  def get(id) do
    TaxRate
    |> QH.get(id, Repo)
    |> case do
      {:ok, tax_rate} ->
        {:ok, Repo.preload(tax_rate, tax_rate_class_values: :tax_class)}

      {:error, _} = error ->
        error
    end
  end

  @doc """
  Returns a list of `TaxRates` preloaded with values for
  tax class it is associated with.
  """
  @spec get_all() :: [TaxRate.t()]
  def get_all() do
    TaxRate |> Repo.all() |> Repo.preload(:tax_rate_class_values)
  end

  @doc """
  Returns all the tax rates for a `tax_zone`.
  """
  @spec get_all_by_tax_zone(non_neg_integer) :: [TaxRate.t()]
  def get_all_by_tax_zone(tax_zone_id) do
    query =
      from(
        tax_rate in TaxRate,
        where: tax_rate.tax_zone_id == ^tax_zone_id,
        select: %TaxRate{
          name: tax_rate.name,
          is_active?: tax_rate.is_active?,
          priority: tax_rate.priority,
          id: tax_rate.id
        }
      )

    query |> Repo.all() |> Repo.preload(tax_rate_class_values: :tax_class)
  end
end
