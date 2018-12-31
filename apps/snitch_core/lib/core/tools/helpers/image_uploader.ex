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
       """
       -filter Triangle
       -define filter:support=2
       -thumbnail 600x800
       -unsharp 0.25x0.25+8+0.065
       -dither None
       -posterize 136
       -quality 82
       -define jpeg:fancy-upsampling=off
       -define png:compression-filter=5
       -define png:compression-level=9
       -define png:compression-strategy=1
       -define png:exclude-chunk=all
       -interlace none
       -colorspace sRGB
       -strip #{input}
       -format jpg jpg:#{output}
       """
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
