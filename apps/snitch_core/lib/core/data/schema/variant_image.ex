defmodule Snitch.Data.Schema.VariantImage do
  use Snitch.Data.Schema
  alias Snitch.Data.Schema.Variant

  @type t :: %__MODULE__{}

  # this schema is going to be deleted
  schema "snitch_variant_images" do
    field(:url, :string)
    belongs_to(:variant, Variant)
  end
end
