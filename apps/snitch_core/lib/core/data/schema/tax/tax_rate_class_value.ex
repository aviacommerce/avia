defmodule Snitch.Data.Schema.TaxRateClassValue do
  @moduledoc """
  Models a TaxRateClassValue

  The TaxRateClassValue model is repsonsible for handling the percent amount to
  be used for a tax rate while calculating taxes.
  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.{TaxRate, TaxClass}
  alias Snitch.Core.Tools.MultiTenancy.Repo

  schema "snitch_tax_rate_class_values" do
    field(:percent_amount, :integer, default: 0)

    belongs_to(:tax_class, TaxClass)
    belongs_to(:tax_rate, TaxRate, on_replace: :delete)

    timestamps()
  end

  @permitted ~w(tax_class_id tax_rate_id percent_amount)a

  def changeset(%__MODULE__{} = data, params) do
    data
    |> cast(params, @permitted)
    |> validate_required([:tax_class_id, :percent_amount])
    |> validate_number(:percent_amount, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:tax_rate_id)
    |> foreign_key_constraint(:tax_class_id)
    |> unique_constraint(:tax_rate_id, name: :unique_tax_rate_class_value)
    |> add_tax_class_data()
  end

  defp add_tax_class_data(changeset) do
    with {:ok, tax_class_id} <- fetch_change(changeset, :tax_class_id) do
      data = %{
        changeset.data
        | tax_class: Repo.get(TaxClass, tax_class_id),
          tax_class_id: tax_class_id
      }

      %{changeset | data: data}
    else
      _ ->
        changeset
    end
  end
end
