defmodule Snitch.Tools.Helper.ImageUploader do
  @moduledoc """
  Helper module for assisting in image upload.

  Contains utilties to store and transform the image.
  """
  use Arc.Definition

  @versions [:original, :thumb]

  # function override to store images locally.
  def __storage do
    Application.get_env(:arc, :storage)
  end

  @doc """
  Validates image file type.
  """
  def validate({file, _}) do
    ~w(.jpg .jpeg .gif .png) |> Enum.member?(Path.extname(file.file_name))
  end

  @doc """
  Defines a thumbnail transformation.

  The function returns a thumbnail version of size 250x250,
  if the version in the storage_dir/2 is `:thumb`. The original
  image as well as it's thumbnail version are stored in that case.
  """
  def transform(:thumb, _) do
    {:convert, "-strip -thumbnail 250x250^ -gravity center -extent 250x250 -format png", :png}
  end

  @doc """
  Overrides the storage directory where images would be stored.
  """
  def storage_dir(_version, {_file, scope}) do
    scope_dir = get_scope_name(scope)
    "uploads/images/#{scope_dir}/#{scope.id}/images/"
  end

  defp get_scope_name(scope) do
    scope.__struct__
    |> to_string()
    |> String.split(".")
    |> Enum.reverse()
    |> hd
    |> String.downcase()
  end
end
