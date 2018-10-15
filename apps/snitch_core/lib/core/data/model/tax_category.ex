defmodule Snitch.Data.Model.TaxCategory do
  @moduledoc """
  Model functions Tax Category.
  """
  use Snitch.Data.Model

  import Ecto.Changeset

  alias Ecto.Multi
  alias Snitch.Core.Tools.MultiTenancy.MultiQuery
  alias Snitch.Data.Schema.TaxCategory

  @doc """
  Creates a TaxCategory in the db with the supplied `params`.

  To create, following fields can be provided in the params
  map:

  | field       | type     |
  | ---------   |  ------  |
  | name        | string   |
  | tax_code    | string   |
  | description | string   |
  | is_default? | boolean  |

  > Note :name field in the params is a `required` field.
  > If `:is_default?` field is set to `true` then the current tax_category
    is set as default and any previous tax category is unset from default.
  ## Example
      params = %{
        name: "Value Added Tax",
        tax_code: "EU_VAT",
        description: "value added tax"
      }
      {:ok, tax_category} = Snitch.Data.Model.TaxCategory.create(params)
  """
  @spec create(map) ::
          {:ok, TaxCategory.t()}
          | {:error, Ecto.Changeset.t()}
  def create(params) do
    changeset = TaxCategory.create_changeset(%TaxCategory{}, params)

    case fetch_change(changeset, :is_default?) do
      {:ok, true} ->
        clear_default_multi()
        |> Multi.run(:tax_category, fn _ ->
          QH.create(TaxCategory, params, Repo)
        end)
        |> persist()

      _ ->
        QH.create(TaxCategory, params, Repo)
    end
  end

  @doc """
  Updates a tax category as per the supplied fields in params.

  The following fields are updatable:

  | field       | type     |
  | ---------   |  ------  |
  | name        | string   |
  | tax_code    | string   |
  | description | string   |
  | is_default  | boolean  |

  ## Note

  If the `:name` field is passed in `params` then it shouldn't be
  empty.
  If `:is_default?` field is set to `true` then the current `tax_category`
  is set as default and any previous tax category is unset from default.

  ## Example
      create_params = %{
        name: "Value Added Tax",
        tax_code: "EU_VAT",
        description: "value added tax"
      }
      {:ok, tax_category} = Snitch.Data.Model.TaxCategory.create(create_params)

      update_params = %{
        name: "Value Added Tax",
        tax_code: "EU_VAT",
        description: "value added tax"
      }
      {:ok, tax_category} =
        Snitch.Data.Model.TaxCategory.update(tax_category, params)
  """
  @spec update(map, TaxCategory.t()) ::
          {:ok, TaxCategory.t()}
          | {:error, Ecto.Changeset.t()}
  def update(params, instance \\ nil) do
    with true <- Map.has_key?(params, :is_default?),
         true <- params.is_default? do
      clear_default_multi()
      |> Multi.run(:tax_category, fn _ ->
        QH.update(TaxCategory, params, instance, Repo)
      end)
      |> persist()
    else
      _ ->
        QH.update(TaxCategory, params, instance, Repo)
    end
  end

  @doc """
  Returns a TaxCategory.

  Takes as input 'id' field and an `active` flag.
  When `active` is false, will return a TaxCategory even
  if it's _soft deleted_.

  > Note, By default tax category which is present in the table
  and is __not soft deleted__ is returned.
  """
  @spec get(integer, boolean) :: TaxCategory.t() | nil
  def get(id, active \\ true) do
    if active do
      query = from(tc in TaxCategory, where: is_nil(tc.deleted_at) and tc.id == ^id)
      Repo.one(query)
    else
      QH.get(TaxCategory, id, Repo)
    end
  end

  @doc """
  Returns a `list` of available tax categories.

  Takes an `active` field. When `active` is false, will
  return all the tax_categories, including those which are
  _soft deleted_.

  > Note the function returns only those tax categories
    which are not soft deleted by default or if `active` is
    set to true.
  """

  @spec get_all(boolean) :: [TaxCategory.t()]
  def get_all(active \\ true) do
    if active do
      query = from(tc in TaxCategory, where: is_nil(tc.deleted_at))
      Repo.all(query)
    else
      Repo.all(TaxCategory)
    end
  end

  @doc """
  Soft deletes a TaxCategory passed to the function.

  Takes as input the `instance` of the TaxCategory to be deleted.
  """
  @spec delete(TaxCategory.t() | integer) ::
          {:ok, TaxCategory.t()}
          | {:error, Ecto.Changeset.t()}
  def delete(id) when is_integer(id) do
    params = %{deleted_at: DateTime.utc_now(), id: id}
    QH.update(TaxCategory, params, Repo)
  end

  def delete(instance) do
    params = %{deleted_at: DateTime.utc_now()}
    QH.update(TaxCategory, params, instance, Repo)
  end

  defp clear_default_multi do
    query = from(tc in TaxCategory, where: tc.is_default? == true)
    MultiQuery.update_all(Multi.new(), :is_default, query, set: [is_default?: false])
  end

  defp persist(multi) do
    case Repo.transaction(multi) do
      {:ok, %{tax_category: tax_category}} ->
        {:ok, tax_category}

      {:error, _, _, _} = error ->
        error
    end
  end
end
