defmodule Snitch.Data.Model.Image do
  @moduledoc """
  Helper functions to handle image uploads.
  """
  use Snitch.Data.Model

  alias Snitch.Data.Schema.Image
  alias Snitch.Data.Schema.GeneralConfiguration, as: GC
  alias Snitch.Tools.Helper.ImageUploader
  alias Ecto.Multi

  def create(module, %{"image" => image} = params, association) do
    multi =
      Multi.new()
      |> Multi.run(:struct, fn _ ->
        QH.create(module, params, Repo)
      end)
      |> Multi.run(:image, fn %{struct: struct} ->
        params = %{"image" => Map.put(image, :url, image_url(image.filename, struct))}
        QH.create(Image, params, Repo)
      end)
      |> Multi.run(:association, fn %{image: image, struct: struct} ->
        params = Map.put(%{}, association, %{image_id: image.id})
        QH.update(module, params, struct, Repo)
      end)
      |> upload_image_multi(image)
      |> persist()
  end

  def update(module, struct, %{"image" => image} = params, association) do
    old_image = struct.image

    Multi.new()
    |> Multi.run(:image, fn _ ->
      params = %{"image" => Map.put(image, :url, image_url(image.filename, struct))}
      QH.create(Image, params, Repo)
    end)
    |> Multi.run(:struct, fn %{image: image} ->
      params = Map.put(params, association, %{image_id: image.id})
      QH.update(module, params, struct, Repo)
    end)
    |> delete_image_multi(old_image, struct)
    |> upload_image_multi(image)
    |> persist()
  end

  def delete(struct, image, changeset) do
    Multi.new()
    |> Multi.run(:delete_struct, fn _ ->
      Repo.delete(changeset)
    end)
    |> delete_image_multi(image, struct)
    |> persist()
  end

  def delete_image_multi(multi, nil, struct) do
    multi
  end

  def delete_image_multi(multi, image, struct) do
    multi
    |> Multi.run(:remove_from_upload, fn _ ->
      case ImageUploader.delete({image.name, struct}) do
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

  def upload_image_multi(multi, %{filename: name, path: path, type: type} = image) do
    Multi.run(multi, :image_upload, fn %{struct: struct} ->
      image = %Plug.Upload{filename: name, path: path, content_type: type}

      case ImageUploader.store({image, struct}) do
        {:ok, _} ->
          {:ok, struct}

        _ ->
          {:error, "upload error"}
      end
    end)
  end

  def persist(multi) do
    case Repo.transaction(multi) do
      {:ok, %{struct: struct} = multi_result} ->
        {:ok, struct}

      {:ok, _} ->
        {:ok, "success"}

      {:error, _, failed_value, _} ->
        {:error, failed_value}
    end
  end

  @doc """
  Returns the url of the location where image is stored.

  Takes as input `name` of the `image` and the corresponding
  struct.
  """
  def image_url(name, struct) do
    ImageUploader.url({name, struct})
  end

  def handle_image_value(%Plug.Upload{} = file) do
    extension = Path.extname(file.filename)
    name = Nanoid.generate() <> extension

    %{}
    |> Map.put(:filename, name)
    |> Map.put(:path, file.path)
    |> Map.put(:type, file.content_type)
  end

  def handle_image_value(_), do: nil
end
