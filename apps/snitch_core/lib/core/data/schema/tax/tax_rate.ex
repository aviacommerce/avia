defmodule Snitch.Data.Schema.TaxRate do
  @moduledoc """
  Models a TaxRate.

  TaxRate belongs to a zone.
  A tax rate basically groups the tax values for different tax classes. These are used
  for tax calculation.
  ### e.g.
  ```
    `ProductTaxClass`: 5%,
    `ShippingTaxClass`: 2%
  ```
  A tax rate has a priority associated with it. While calculating taxes for a `tax_zone` the tax
  rates with lowest priority are calculated first.
  After this the taxes are compounded upon the one created with lower priority.
  ### Example
    ```
      tax_rate_1: %{priority: 0, rate: 2%},
      tax_rate_2: %{priority: 0, rate: 3%},
      tax_rate_3: %{priority: 1, rate: 1%}

      base_amount = 10
      level_1_amount = 10 * 0.02 + 10 * 0.01 + 10
      total_amount = 0.01 * level_1_amount
    ```
    Here first taxes due to tax_rate_1 and tax_rate_2 are calculated on the base amount which
    are added together to give a level_1_amount. The tax_rate_3 is then applied on this to give
    total amount.
  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.{TaxZone, TaxRateClassValue}

  @type t :: %__MODULE__{}

  schema "snitch_tax_rates" do
    field(:name, :string)
    field(:priority, :integer, default: 0)
    field(:is_active?, :boolean, default: true)

    belongs_to(:tax_zone, TaxZone)
    has_many(:tax_rate_class_values, TaxRateClassValue, on_replace: :delete)

    timestamps()
  end

  @required ~w(name tax_zone_id)a
  @optional ~w(is_active? priority)a
  @permitted @required ++ @optional

  def create_changeset(%__MODULE__{} = tax_rate, params) do
    tax_rate
    |> cast(params, @permitted)
    |> common_changeset()
  end

  def update_changeset(%__MODULE__{} = tax_rate, params) do
    tax_rate
    |> cast(params, @permitted)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> validate_required(@required)
    |> foreign_key_constraint(:tax_zone_id)
    |> unique_constraint(:name,
      name: :unique_tax_rate_name_for_tax_zone,
      message: "Tax Rate name should be unique for a tax zone."
    )
    |> cast_assoc(:tax_rate_class_values,
      with: &TaxRateClassValue.changeset/2,
      required: true
    )
  end
end
