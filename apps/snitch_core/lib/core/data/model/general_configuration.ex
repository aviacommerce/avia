defmodule Snitch.Data.Model.GeneralConfiguration do
  @moduledoc """
  General configuration CRUD and helpers
  """

  use Snitch.Data.Model

  alias Snitch.Data.Schema.Image
  alias Snitch.Data.Schema.GeneralConfiguration, as: GC
  alias Snitch.Tools.Helper.ImageUploader
  alias Ecto.Multi

  @currency_list ["USD", "INR", "GDP", "EUR"]

  @spec fetch_currency() :: String.t()
  def fetch_currency do
    case Repo.one(GC) do
      nil -> "USD"
      gc -> gc.currency
    end
  end

  @spec get_currency_list() :: List.t()
  def get_currency_list do
    @currency_list
  end

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

  @spec delete_general_configuration(integer) :: {:ok, GC.t()} | {:error, Ecto.Changeset.t()}
  def delete_general_configuration(id) do
    QH.delete(GC, id, Repo)
  end

  def create(%{"image" => image} = params) do
    multi =
      Multi.new()
      |> Multi.run(:image, fn _ ->
        QH.create(Image, params, Repo)
      end)
      |> Multi.run(:general_configuration, fn _ ->
        QH.create(GC, params, Repo)
      end)
      |> Multi.run(:image_store, fn %{image: image, general_configuration: general_configuration} ->
        params = Map.put(%{}, :store_image, %{image_id: image.id})
        QH.update(GC, params, general_configuration, Repo)
      end)
      |> upload_image_multi(image)
      |> persist()
  end

  def create(params) do
    QH.create(GC, params, Repo)
  end

  def update(store, %{image: image} = params) do
    old_image = store.image

    Multi.new()
    |> Multi.run(:image, fn _ ->
      QH.create(Image, params, Repo)
    end)
    |> Multi.run(:general_configuration, fn %{image: image} ->
      params = Map.put(params, :store_image, %{image_id: image.id})
      QH.update(GC, params, store, Repo)
    end)
    |> delete_image_multi(old_image, store)
    |> upload_image_multi(params.image)
    |> persist()
  end

  def update(store, params) do
    QH.update(GC, params, store, Repo)
  end

  defp delete_image_multi(multi, nil, store) do
    multi
  end

  defp delete_image_multi(multi, image, store) do
    multi
    |> Multi.run(:remove_from_upload, fn _ ->
      case ImageUploader.delete({image.name, store}) do
        :ok ->
          {:ok, "success"}

        _ ->
          {:error, "not_found"}
      end
    end)
    |> Multi.run(:delete_image, fn _ ->
      QH.delete(Image, image.id, Repo)
    end)
  end

  defp upload_image_multi(multi, %Plug.Upload{} = image) do
    Multi.run(multi, :image_upload, fn %{general_configuration: general_config} ->
      case ImageUploader.store({image, general_config}) do
        {:ok, _} ->
          {:ok, general_config}

        _ ->
          {:error, "upload error"}
      end
    end)
  end

  defp persist(multi) do
    case Repo.transaction(multi) do
      {:ok, multi_result} ->
        {:ok, multi_result.general_configuration}

      {:error, _, failed_value, _} ->
        {:error, failed_value}
    end
  end

  def image_url(name, general_config) do
    ImageUploader.url({name, general_config})
  end
end
