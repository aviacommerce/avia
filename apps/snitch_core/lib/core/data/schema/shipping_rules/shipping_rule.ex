defmodule Snitch.Data.Schema.ShippingRule do
  @moduledoc """
  Models the rules to be used while calculating shipping cost for
  a shipping category.
  """

  use Snitch.Data.Schema

  alias Snitch.Data.Schema.{ShippingCategory, ShippingRuleIdentifier}

  @type t :: %__MODULE__{}

  @doc """
  Returns the shipping cost applied.

  Returns {:halt, Money.t()} if the shipping rule is of highest order
  and the shipping rule overrides all other in a single run of
  `Snitch.Domain.ShippingCalculator.calculate/1`.

  Returns {:cont, Money.t()} if further rules can also be applied in a
  single run of `Snitch.Domain.ShippingCalculator.calculate/1`.

  The `prev_cost` field is overriden by the module adopting the
  behaviour if the rule applies.
  """
  @callback calculate(
              package :: Package.t(),
              currency_code :: atom(),
              rule :: ShippingRule.t(),
              prev_cost :: Money.t()
            ) ::
              {:halt, cost :: Money.t()}
              | {:cont, cost :: Money.t()}

  schema "snitch_shipping_rules" do
    field(:active?, :boolean, default: false)
    field(:preferences, :map)

    # associations
    belongs_to(:shipping_rule_identifier, ShippingRuleIdentifier)
    belongs_to(:shipping_category, ShippingCategory)

    timestamps()
  end

  @required_fields ~w(shipping_rule_identifier_id shipping_category_id)a
  @optional_fields ~w(active? preferences)a ++ @required_fields

  def changeset(%__MODULE__{} = rule, params) do
    rule
    |> cast(params, @optional_fields)
    |> validate_required(@required_fields)
    |> validate_preference_with_target()
    |> foreign_key_constraint(:shipping_rule_identifier_id)
    |> foreign_key_constraint(:shipping_category_id)
    |> unique_constraint(:unique_identifier_for_category,
      name: :unique_rule_per_category_for_identifier
    )
  end

  defp validate_preference_with_target(%Ecto.Changeset{valid?: true} = changeset) do
    with {:ok, preferences} <- fetch_change(changeset, :preferences) do
      module = get_preference_module(changeset)
      preference_changeset = module.changeset(struct(module), preferences)
      add_preferences_change(preference_changeset, changeset)
    else
      :error ->
        changeset
    end
  end

  defp validate_preference_with_target(changeset), do: changeset

  defp add_preferences_change(%Ecto.Changeset{valid?: true} = pref_changeset, changeset) do
    data = pref_changeset.changes
    put_change(changeset, :preferences, data)
  end

  defp add_preferences_change(pref_changeset, changeset) do
    message =
      pref_changeset
      |> traverse_errors(fn {msg, opts} ->
        Enum.reduce(opts, msg, fn {key, value}, acc ->
          String.replace(acc, "%{#{key}}", to_string(value))
        end)
      end)
      |> Enum.reduce("", fn {key, value}, acc ->
        acc <> "#{key} #{value}. "
      end)

    add_error(changeset, :preferences, message)
  end

  defp get_preference_module(changeset) do
    identifier_id =
      with {:ok, id} <- fetch_change(changeset, :shipping_rule_identifier_id) do
        id
      else
        :error ->
          changeset.data.shipping_rule_identifier_id
      end

    identifier = Repo.get(ShippingRuleIdentifier, identifier_id)

    identifiers = ShippingRuleIdentifier.identifier_with_module()

    identifiers[identifier.code].module
  end
end
