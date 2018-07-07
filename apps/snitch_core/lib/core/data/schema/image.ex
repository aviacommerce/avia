defmodule Snitch.Data.Schema.Image do
  @moduledoc """
  Models a Image
  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.Variant

  @type t :: %__MODULE__{}

  schema "snitch_images" do
    field(:url, :string)
    belongs_to(:variant, Variant)
  end
end
