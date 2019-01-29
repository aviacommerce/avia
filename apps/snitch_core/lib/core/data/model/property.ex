defmodule Snitch.Data.Model.Property do
  @moduledoc """
  Property API
  """
  use Snitch.Data.Model

  alias Snitch.Data.Schema.Property

  @doc """
  Returns all Property
  """
  @spec get_all() :: [Property.t()]
  def get_all do
    Repo.all(Property)
  end

  @doc """
  Create a Property with supplied params
  """
  @spec create(map) :: {:ok, Property.t()} | {:error, Ecto.Changeset.t()}
  def create(params) do
    QH.create(Property, params, Repo)
  end

  @doc """
  Update the Property with supplied params and Property instance
  """
  @spec update(Property.t(), map) :: {:ok, Property.t()} | {:error, Ecto.Changeset.t()}
  def update(model, params) do
    QH.update(Property, params, model, Repo)
  end

  @doc """
  Returns an Property

  Takes Property id as input
  """
  @spec get(integer) :: {:ok, Property.t()} | {:error, atom}
  def get(id) do
    QH.get(Property, id, Repo)
  end

  @doc """
  Deletes the Property
  """
  @spec delete(non_neg_integer() | Property.t()) ::
          {:ok, Property.t()} | {:error, Ecto.Changeset.t()} | {:error, :not_found}
  def delete(id) when is_integer(id) do
    QH.delete(Property, id, Repo)
  end

  def delete(instance) do
    QH.delete(Property, instance, Repo)
  end

  def get_formatted_list() do
    Property
    |> order_by([p], asc: p.display_name)
    |> select([p], {p.display_name, p.id})
    |> Repo.all()
  end
end
