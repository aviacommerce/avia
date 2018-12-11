defmodule Snitch.Data.Schema.ImageTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory
  import Ecto.Changeset, only: [apply_changes: 1]

  alias Snitch.Data.Schema.Image

  test "update changeset for an image" do
    image = insert(:image)
    attrs = %{is_default: false}
    updated_image = Image.update_changeset(image, attrs)
    assert updated_image.changes == %{is_default: false}
  end
end
