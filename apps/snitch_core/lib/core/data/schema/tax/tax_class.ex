defmodule Snitch.Data.Schema.TaxClass do
  @moduledoc """
  Models TaxClasses.

  Tax Classes are templates which are used for setting different
  rates for a particular type of tax_rate.
  e.g.
    GST can have different tax brackets for different types of products:
    - A_CLOTHING
    - A_ELECTRONICS
    etc.
  """

  use Snitch.Data.Schema

  @type t :: %__MODULE__{}

  schema "snitch_tax_classes" do
    field(:name, :string)
    field(:is_default, :boolean, default: false)

    timestamps()
  end

  @permitted ~w(name is_default)a

  def create_changeset(%__MODULE__{} = tax_class, params) do
    common_changeset(tax_class, params)
  end

  def update_changeset(%__MODULE__{} = tax_class, params) do
    common_changeset(tax_class, params)
  end

  defp common_changeset(tax_class, params) do
    tax_class
    |> cast(params, @permitted)
    |> validate_required(@permitted)
    |> unique_constraint(:name, message: "unique name for classes")
    |> unique_constraint(:is_default,
      message: "unique default class",
      name: :unique_default_tax_class
    )
  end
end
