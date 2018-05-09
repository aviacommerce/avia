defmodule Snitch.Data.Schema.TaxRate do
  @moduledoc """
  Models a TaxRate
  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.{TaxCategory, Zone}
  alias Snitch.Domain.Calculator

  @type t :: %__MODULE__{}

  schema "snitch_tax_rates" do
    # associations
    belongs_to(:tax_category, TaxCategory)
    belongs_to(:zone, Zone)

    field(:name, :string)
    field(:value, :decimal)
    field(:calculator, Ecto.Atom)
    field(:deleted_at, :utc_datetime)
    field(:included_in_price, :boolean, default: false)

    timestamps()
  end

  @required_params ~w(name value tax_category_id calculator zone_id )a
  @optional_params ~w(deleted_at)a
  @create_params @required_params ++ @optional_params
  @update_params @required_params ++ @optional_params

  @doc """
  Returns a changeset to create a new TaxRate.
  """
  @spec create_changeset(t, map) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = tax_rate, params) do
    tax_rate
    |> cast(params, @create_params)
    |> validate_required(@required_params)
    |> common_changeset()
  end

  @doc """
  Returns a changeset to update a TaxRate.
  """
  @spec update_changeset(t, map) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = tax_rate, params) do
    tax_rate
    |> cast(params, @update_params)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> validate_required(:name)
    |> validate_number(:value, greater_than: 0)
    |> modify_calculator_name()
    |> verify_calculator()
    |> unique_constraint(:name, name: :unique_name_per_zone)
  end

  defp modify_calculator_name(%Ecto.Changeset{valid?: true} = changeset) do
    case fetch_change(changeset, :calculator) do
      {:ok, calculator} ->
        put_change(changeset, :calculator, Module.safe_concat(Elixir, calculator))

      :error ->
        changeset
    end
  end

  defp modify_calculator_name(changeset), do: changeset

  defp verify_calculator(%Ecto.Changeset{valid?: true} = changeset) do
    calc_list = Calculator.list()

    with {:ok, calculator} <- fetch_change(changeset, :calculator),
         true <- Enum.member?(calc_list, calculator) do
      changeset
    else
      :error ->
        changeset

      false ->
        add_error(
          changeset,
          :calculator,
          "invalid calculator",
          additional: "not specified in calculator list"
        )
    end
  end

  defp verify_calculator(changeset), do: changeset
end
