defmodule Snitch.Data.Model.TaxClass do
  @moduledoc """
  Module exposes CRUD APIs for TaxClass.
  """

  use Snitch.Data.Model
  alias Snitch.Data.Schema.TaxClass

  @doc """
  Creates a TaxClass.
  """
  @spec create(map) :: {:ok, TaxClass.t()} | {:error, Ecto.Changeset.t()}
  def create(params) do
    QH.create(TaxClass, params, Repo)
  end

  @doc """
  Updates a TaxClass as per the supplied params.

  ## Note
  The `is_default` field can not be set to true if a default tax class
  already exists.
  """
  @spec update(TaxClass.t(), map) :: {:ok, TaxClass.t()} | {:error, Ecto.Changeset.t()}
  def update(tax_class, params) do
    QH.update(TaxClass, params, tax_class, Repo)
  end

  @doc """
  Deletes a TaxClass.

  ## Note
  The default tax class, for which `is_default` field is true, can not be deleted.
  """
  @spec delete(non_neg_integer | TaxClass.t()) ::
          {:ok, TaxClass.t()}
          | {:error, Ecto.Changeset.t()}
          | {:error, String.t()}
  def delete(id) when is_integer(id) do
    with {:ok, instance} <- get(id) do
      delete(instance)
    else
      {:error, _data} = error ->
        error
    end
  end

  def delete(instance) do
    with false <- instance.is_default do
      try do
        QH.delete(TaxClass, instance, Repo)
      rescue
        Ecto.ConstraintError ->
          {:error, "Tax class associated with some entity, consider removing the association"}
      end
    else
      true ->
        {:error, "can not delete default tax class"}
    end
  end

  @spec get(map | non_neg_integer) :: {:ok, TaxClass.t()} | {:error, atom}
  def get(query_fields_or_primary_key) do
    QH.get(TaxClass, query_fields_or_primary_key, Repo)
  end

  @spec get_all :: [TaxClass.t()]
  def get_all, do: Repo.all(TaxClass)

  @spec formatted_list() :: [{String.t(), non_neg_integer}]
  def formatted_list do
    TaxClass
    |> order_by([s], asc: s.name)
    |> select([s], {s.name, s.id})
    |> Repo.all()
  end
end
