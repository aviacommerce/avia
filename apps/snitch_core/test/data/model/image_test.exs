defmodule Snitch.Data.Model.ImageTest do
  use ExUnit.Case
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Data.Model.Image
  alias Snitch.Repo

  describe "handle image value" do
    test "with %Plug.Upload{} params" do
      file = %Plug.Upload{
        filename: "abc.png",
        content_type: "image/png",
        path: "/xyz"
      }

      image_map = Image.handle_image_value(file)
      refute is_nil(image_map.filename)
      refute is_nil(image_map.path)
      refute is_nil(image_map.type)
    end

    test "with empty params" do
      image_map = Image.handle_image_value(%{})
      assert image_map == nil
    end
  end
end
