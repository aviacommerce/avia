defmodule Snitch.Data.Schema.TaxCategory do
  @moduledoc """
  Models a Tax Category.

  A TaxCategory has many TaxRates.
  """
  use Snitch.Data.Schema

  @type t :: %__MODULE__{}

  schema "snitch_tax_categories" do
    field(:name, :string)
    field(:description, :string)
    field(:tax_code, :string)
    field(:is_default?, :boolean, default: false)

    field(:deleted_at, :utc_datetime)

    timestamps()
  end

  @required_fields ~w(name)a
  @optional_fields ~w(description tax_code is_default? deleted_at)a
  @create_fields @optional_fields ++ @required_fields
  @update_fields @optional_fields ++ @required_fields

  @doc """
  Returns a changeset to create a new TaxCategory.

  > Note, :name is a required field and it should be unique.
  """
  @spec create_changeset(t, map) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = tax_category, params) do
    tax_category
    |> cast(params, @create_fields)
    |> common_changeset()
  end

  @doc """
  Returns a changeset to update a TaxCategory.
  """
  @spec update_changeset(t, map) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = tax_category, params) do
    tax_category
    |> cast(params, @update_fields)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> validate_required(@required_fields)
    |> unique_constraint(:name)
  end
end
