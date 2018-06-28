defmodule Snitch.Data.Model.OptionType do
  @moduledoc """
  OptionType API
  """
  use Snitch.Data.Model
  alias Snitch.Data.Schema.OptionType

  @doc """
  Create a OptionType with supplied params
  """
  @spec create(map) :: {:ok, OptionType.t()} | {:error, Ecto.Changeset.t()}
  def create(params) do
    QH.create(OptionType, params, Repo)
  end

  @doc """
  Returns all OptionTypes
  """
  @spec get_all() :: [OptionType.t()]
  def get_all do
    Repo.all(OptionType)
  end

  @doc """
  Returns an OptionType

  Takes OptionType id as input
  """
  @spec get(integer) :: OptionType.t() | nil
  def get(id) do
    QH.get(OptionType, id, Repo)
  end

  @doc """
  Update the OptionType with supplied params and OptionType instance
  """
  @spec update(OptionType.t(), map) :: {:ok, OptionType.t()} | {:error, Ecto.Changeset.t()}
  def update(model, params) do
    QH.update(OptionType, params, model, Repo)
  end

  @doc """
  Deletes the OptionType
  """
  @spec delete(non_neg_integer | struct()) ::
          {:ok, OptionType.t()} | {:error, Ecto.Changeset.t()} | {:error, :not_found}
  def delete(id) when is_integer(id) do
    QH.delete(OptionType, id, Repo)
  end

  def delete(%OptionType{} = instance) do
    QH.delete(OptionType, instance, Repo)
  end
end
