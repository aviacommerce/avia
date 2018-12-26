defmodule Snitch.Data.Schema.PromotionAction.LineItemAction do
  @moduledoc """
  Models the actions to be applied for an `order`.
  """

  use Snitch.Data.Schema
  alias Snitch.Data.Model.Promotion
  alias Snitch.Data.Model.PromotionAdjustment

  @behaviour Snitch.Data.Schema.PromotionAction
  @type t :: %__MODULE__{}

  embedded_schema do
    field(:calculator_module, ActionCalculators)
    field(:calculator_preferences, :map)
  end

  @params ~w(calculator_module calculator_preferences)a

  def changeset(%__MODULE__{} = order_action, params) do
    order_action
    |> cast(params, @params)
    |> validate_required(@params)
    |> validate_calculator_preferences()
  end

  def perform?(order, promotion, action) do
    order = Repo.preload(order, line_items: :product)
    action_data = action.preferences
    calculator = String.to_existing_atom(action_data["calculator_module"])

    params =
      for {key, value} <- action_data["calculator_preferences"], into: %{} do
        {String.to_existing_atom(key), value}
      end

    adjustments =
      Enum.map(order.line_items, fn line_item ->
        if Promotion.line_item_actionable?(line_item, promotion) do
          amount = order |> calculator.compute(params) |> Decimal.mult(-1)
          create_line_item_adjustment(order, promotion, action, amount, line_item)
        else
          false
        end
      end)

    Enum.any?(adjustments, fn adj -> adj == true end)
  end

  ########################  private functions #################

  defp create_line_item_adjustment(order, promotion, action, amount, item) do
    params = set_adjustment_params(order, promotion, action, amount, item)

    case PromotionAdjustment.create(params) do
      {:ok, _data} ->
        true

      {:error, _data} ->
        false
    end
  end

  defp set_adjustment_params(order, promotion, action, amount, item) do
    %{
      order: order,
      promotion: promotion,
      promotion_action: action,
      amount: amount,
      adjustable_type: :line_item,
      adjustable_id: item.id
    }
  end

  defp validate_calculator_preferences(%Ecto.Changeset{valid?: true} = changeset) do
    with {:ok, module} <- fetch_change(changeset, :calculator_module),
         {:ok, preferences} <- fetch_change(changeset, :calculator_preferences) do
      preference_changeset = module.changeset(struct(module), preferences)
      add_preferences_change(preference_changeset, changeset)
    else
      :error ->
        changeset
    end
  end

  defp validate_calculator_preferences(changeset), do: changeset

  defp add_preferences_change(%Ecto.Changeset{valid?: true} = pref_changeset, changeset) do
    data = pref_changeset.changes
    put_change(changeset, :calculator_preferences, data)
  end

  defp add_preferences_change(pref_changeset, changeset) do
    additional_info =
      pref_changeset
      |> traverse_errors(fn {msg, opts} ->
        Enum.reduce(opts, msg, fn {key, value}, acc ->
          String.replace(acc, "%{#{key}}", to_string(value))
        end)
      end)

    add_error(changeset, :calculator_preferences, "invalid_preferences", additional_info)
  end
end
