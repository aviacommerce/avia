defmodule Snitch.Data.Schema.Image do
  @moduledoc """
  Models an Image.
  """

  use Snitch.Data.Schema

  @type t :: %__MODULE__{}

  schema "snitch_images" do
    field(:url, :string)

    timestamps()
  end
end
