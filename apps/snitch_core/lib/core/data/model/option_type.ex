defmodule Snitch.Data.Model.OptionType do
  @moduledoc """
  OptionType API
  """
  use Snitch.Data.Model
  alias Snitch.Data.Schema.OptionType
  alias Snitch.Data.Schema.Product
  alias Snitch.Core.Tools.MultiTenancy.Repo
  import Ecto.Query

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
  @spec get(integer) :: {:ok, OptionType.t()} | {:error, atom}
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

  @doc """
  Checks whether the OptionType is associated to any product's variation theme.
  """
  @spec is_theme_associated(non_neg_integer) :: true | false
  def is_theme_associated(option_type_id) do
    option_preloader = from(ot in OptionType, where: ot.id == ^option_type_id)

    products =
      from(p in Product, preload: [theme: [option_types: ^option_preloader]]) |> Repo.all()

    Enum.any?(products, fn product ->
      if product.theme != nil, do: length(product.theme.option_types) > 0
    end)
  end
end
