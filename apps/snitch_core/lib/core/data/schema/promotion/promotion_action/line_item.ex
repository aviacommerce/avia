defmodule Snitch.Data.Schema.PromotionAction.LineItemAction do
  @moduledoc """
  Models the actions to be applied for an `line_item`.

  Makes use of `calculator's` to apply adjustments.
  """

  use Snitch.Data.Schema
  alias Snitch.Data.Model.Promotion
  alias Snitch.Data.Model.PromotionAdjustment
  alias Snitch.Tools.Validations

  @behaviour Snitch.Data.Schema.PromotionAction

  @typedoc """
  Represents LineItemAction struct.

  Fields:
  - `calculator_module`: The calculator module used for calculating the discount
     amount.
  - `calculator_preferences`: Meta data required for performing the caculations.
        e.g.
          calculator: `Snitch.Domain.Calculator.FlatPercent`
          data: flat `percent_amount`for this calculator is stored by
          `calculator_preferences`.

  """
  @type t :: %__MODULE__{}
  @name "per line item adjustment"

  embedded_schema do
    field(:calculator_module, ActionCalculators)
    field(:calculator_preferences, :map)
  end

  @params ~w(calculator_module calculator_preferences)a

  def changeset(%__MODULE__{} = order_action, params) do
    order_action
    |> cast(params, @params)
    |> validate_required(@params)
    |> Validations.validate_embedded_data(
      :calculator_module,
      :calculator_preferences
    )
  end

  def perform?(order, promotion, action) do
    order = Repo.preload(order, line_items: :product)
    action_preferences = action.preferences
    calculator = String.to_existing_atom(action_preferences["calculator_module"])

    params =
      for {key, value} <- action_preferences["calculator_preferences"], into: %{} do
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

  def action_name() do
    @name
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
end
