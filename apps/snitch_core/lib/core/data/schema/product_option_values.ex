defmodule Snitch.Data.Schema.ProductOptionValue do
  @moduledoc false

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.{OptionType, Product}

  schema "snitch_product_option_values" do
    field(:value, :string)
    field(:display_name, :string)

    belongs_to(:option_type, OptionType)
    belongs_to(:product, Product)

    timestamps()
  end

  def changeset(model, params) do
    model
    |> cast(params, [:option_type_id, :product_id, :value])
    |> validate_required([:option_type_id, :value])
  end

  def update_changeset(model, params) do
    model
    |> cast(params, [:value])
    |> validate_required([:value])
  end
end
