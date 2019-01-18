defmodule Snitch.Data.Model.VariationTheme do
  @moduledoc """
  Variation theme API
  """

  use Snitch.Data.Model

  alias Snitch.Data.Schema.VariationTheme

  @doc """
  Returns all Variation themes
  """
  def get_all do
    Repo.all(VariationTheme)
  end

  @doc """
  Create a Variation theme with supplied params
  """
  def create(params) do
    QH.create(VariationTheme, params, Repo)
  end

  @doc """
  Takes Variation theme id as input
  """
  @spec get(integer) :: {:ok, VariationTheme.t()} | {:error, atom}
  def get(id) do
    QH.get(VariationTheme, id, Repo)
  end

  @doc """
  Update the Variation theme with supplied params and variation theme instance
  """
  @spec update(VariationTheme.t(), map) ::
          {:ok, VariationTheme.t()} | {:error, Ecto.Changeset.t()}
  def update(model, params) do
    QH.update(VariationTheme, params, model, Repo)
  end

  @doc """
  Deletes the Variation theme
  """
  @spec delete(non_neg_integer | struct() | binary) ::
          {:ok, VariationTheme.t()} | {:error, Ecto.Changeset.t()} | {:error, :not_found}
  def delete(id) when is_integer(id) or is_binary(id) do
    QH.delete(VariationTheme, id, Repo)
  end

  def delete(%VariationTheme{} = instance) do
    QH.delete(VariationTheme, instance, Repo)
  end
end
