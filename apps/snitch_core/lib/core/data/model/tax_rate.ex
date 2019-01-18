defmodule Snitch.Data.Model.TaxRate do
  @moduledoc """
  Model functions TaxRate.
  """

  use Snitch.Data.Model
  alias Snitch.Data.Schema.TaxRate

  @doc """
  Creates a TaxRate with supplied `params`.

  > ### Note
    The `calculator` field should be converted to an `atom`
    before passing in the `params` map.
  """
  @spec create(map) :: {:ok, TaxRate.t()} | {:error, Ecto.Changeset.t()}
  def create(params) do
    QH.create(TaxRate, params, Repo)
  end

  @doc """
  Updates an existing TaxRate with supplied `params`.

  > ### Note
    The `calculator` field should be converted to an `atom`
    before passing in the `params` map.
  """
  @spec update(map, TaxRate.t() | nil) ::
          {:ok, TaxRate.t()}
          | {:error, Ecto.Changeset.t()}
  def update(params, instance \\ nil) do
    QH.update(TaxRate, params, instance, Repo)
  end

  @doc """
  Soft deletes a TaxRate.

  Takes as input the `instance` or `id` of the TaxRate to be deleted.
  """
  @spec delete(TaxRate.t() | integer) ::
          {:ok, TaxRate.t()}
          | {:error, Ecto.Changeset.t()}
  def delete(id) when is_integer(id) do
    params = %{deleted_at: DateTime.utc_now(), id: id}
    QH.update(TaxRate, params, Repo)
  end

  def delete(instance) do
    params = %{deleted_at: DateTime.utc_now()}
    QH.update(TaxRate, params, instance, Repo)
  end

  @doc """
  Returns a TaxRate.

  Takes as input 'id' field and an `active` flag.
  When `active` is false, will return a TaxRate even
  if it's _soft deleted_.

  > Note, By default tax rate which is present in the table
  and is __not soft deleted__ is returned.
  """
  @spec get(integer, boolean) :: {:ok, TaxRate.t()} | {:error, atom}
  def get(id, active \\ true) do
    if active do
      query = from(tc in TaxRate, where: is_nil(tc.deleted_at) and tc.id == ^id)
      Repo.one(query)
    else
      QH.get(TaxRate, id, Repo)
    end
  end

  @doc """
  Returns a `list` of available tax rates.

  Takes an `active` field. When `active` is false, will
  return all the tax_rates, including those which are
  _soft deleted_.

  > Note the function returns only those tax rates
    which are not soft deleted by default or if `active` is
    set to true.
  """

  @spec get_all(boolean) :: [TaxRate.t()]
  def get_all(active \\ true) do
    if active do
      query = from(tc in TaxRate, where: is_nil(tc.deleted_at))
      Repo.all(query)
    else
      Repo.all(TaxRate)
    end
  end
end
