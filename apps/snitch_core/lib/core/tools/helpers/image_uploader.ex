defmodule Snitch.Tools.Helper.ImageUploader do
  @moduledoc """
  Helper module for assisting in image upload.

  Contains utilties to store and transform the image.
  """
  use Arc.Definition

  @versions [:original]

  # function override to store images locally.
  def __storage do
    Application.get_env(:arc, :storage)
  end

  @doc """
  Validates image file type.
  """
  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()
    ~w(.jpg .jpeg .gif .png) |> Enum.member?(file_extension)
  end

  def transform(:original, _) do
    {:convert,
     fn input, output ->
       "#{input} -strip -gravity center -extent 600x800 -format jpg jpg:#{output}"
     end, :jpg}
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
