defmodule Snitch.Data.Model.GeneralConfiguration do
  @moduledoc """
  General configuration CRUD and helpers
  """

  use Snitch.Data.Model

  alias Snitch.Data.Schema.GeneralConfiguration, as: GC

  @spec build_general_configuration(map) :: Ecto.Changeset.t()
  def build_general_configuration(attrs \\ %{}) do
    %GC{} |> GC.create_changeset(attrs)
  end

  @spec get_general_configuration(integer) :: GC.t() | nil
  def get_general_configuration(id) do
    QH.get(GC, id, Repo)
  end

  @spec list_general_configuration() :: [GC.t()]
  def list_general_configuration() do
    Repo.all(GC)
  end

  @spec create(map) :: {:ok, GC.t()} | {:error, Ecto.Changeset.t()}
  def create(params) do
    QH.create(GC, params, Repo)
  end

  @spec update_general_configuration(GC.t(), map) :: {:ok, GC.t()} | {:error, Ecto.Changeset.t()}
  def update_general_configuration(params, store) do
    QH.update(GC, params, store, Repo)
  end

  @spec delete_general_configuration(integer) :: {:ok, GC.t()} | {:error, Ecto.Changeset.t()}
  def delete_general_configuration(id) do
    QH.delete(GC, id, Repo)
  end
end
