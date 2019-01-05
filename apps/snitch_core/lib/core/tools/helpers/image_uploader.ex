defmodule Snitch.Tools.Helper.ImageUploader do
  @moduledoc """
  Helper module for assisting in image upload.

  Contains utilties to store and transform the image.
  """
  use Arc.Definition
  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias Snitch.Data.Model.Image

  @versions [:thumb, :large, :small]
  @cwd File.cwd!()

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

  def transform(:large, _) do
    {:convert, &image_formatter(&1, &2, "600x800"), :jpg}
  end

  def transform(:small, _) do
    {:convert, &image_formatter(&1, &2, "90x120"), :jpg}
  end

  def transform(:thumb, _) do
    {:convert, &image_formatter(&1, &2, "210x280"), :jpg}
  end

  def storage_dir(version, {_file, scope}) do
    scope_dir = get_scope_name(scope)
    dir = "uploads/#{scope.tenant}/images/#{scope_dir}/#{scope.id}/images/#{version}"

    case Image.check_arc_config() do
      true ->
        base_path = String.replace(@cwd, "snitch_core", "admin_app")

        "#{base_path}/#{dir}"

      false ->
        dir
    end
  end

  defp get_scope_name(scope) do
    scope.__struct__
    |> to_string()
    |> String.split(".")
    |> Enum.reverse()
    |> hd
    |> String.downcase()
  end

  defp image_formatter(input, output, size) do
    """
    #{input}
    -filter Triangle
    -define filter:support=2
    -thumbnail #{size}
    -unsharp 0.25x0.25+8+0.065
    -dither None
    -posterize 136
    -quality 85
    -define jpeg:fancy-upsampling=off
    -define png:compression-filter=5
    -define png:compression-level=9
    -define png:compression-strategy=1
    -define png:exclude-chunk=all
    -interlace Plane
    -colorspace sRGB
    -background white
    -alpha remove
    -strip
    -format jpg jpg:#{output}
    """
  end
end
