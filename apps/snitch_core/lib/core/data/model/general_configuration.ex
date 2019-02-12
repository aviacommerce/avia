defmodule Snitch.Data.Model.GeneralConfiguration do
  @moduledoc """
  General configuration CRUD and helpers
  """

  use Snitch.Data.Model

  alias Snitch.Data.Schema.Image
  alias Snitch.Data.Schema.GeneralConfiguration, as: GC
  alias Snitch.Tools.Helper.ImageUploader
  alias Snitch.Data.Model.Image, as: ImageModel
  alias Ecto.Multi
  alias Snitch.Tools.Cache

  @currency_list ["USD", "INR", "GBP", "EUR"]

  @spec fetch_currency() :: String.t()
  def fetch_currency do
    Cache.get(
      Repo.get_prefix() <> "_gc_currency",
      {
        fn ->
          case Repo.one(GC) do
            nil -> "USD"
            gc -> gc.currency
          end
        end,
        []
      }
    )
  end

  @spec get_currency_list() :: List.t()
  def get_currency_list do
    @currency_list
  end

  @spec build_general_configuration(map) :: Ecto.Changeset.t()
  def build_general_configuration(attrs \\ %{}) do
    %GC{} |> GC.create_changeset(attrs)
  end

  @spec get_general_configuration(integer) :: {:ok, GC.t()} | {:error, atom}
  def get_general_configuration(id) do
    QH.get(GC, id, Repo)
  end

  @spec list_general_configuration() :: [GC.t()]
  def list_general_configuration() do
    Repo.all(GC)
  end

  @spec delete_general_configuration(integer) :: {:ok, GC.t()} | {:error, Ecto.Changeset.t()}
  def delete_general_configuration(id) do
    QH.delete(GC, id, Repo)
  end

  def create(%{"image" => image} = params) do
    ImageModel.create(GC, params, "store_image")
  end

  def create(params) do
    QH.create(GC, params, Repo)
  end

  def update(store, %{"image" => image} = params) do
    ImageModel.update(GC, store, params, "store_image")
  end

  def update(store, params) do
    QH.update(GC, params, store, Repo)
  end
end
