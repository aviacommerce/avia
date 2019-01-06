defmodule Snitch.Data.Schema.PromotionAction.OrderAction do
  @moduledoc """
  Models the actions to be applied for an `order`.
  """

  use Snitch.Data.Schema
  alias Snitch.Data.Model.PromotionAdjustment
  alias Snitch.Tools.Validations

  @behaviour Snitch.Data.Schema.PromotionAction

  @typedoc """
  Represents OrderAction struct.

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
  @name "whole order adjustment"

  embedded_schema do
    # The field is using ActionCalculators enum but it has no
    # effect because it is being handled manually at present and the
    # dump and load is not being used since the data is being stored
    # as embedded schema which is also dynamic
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
    action_preferences = action.preferences
    calculator = String.to_existing_atom(action_preferences["calculator_module"])

    params =
      for {key, value} <- action_preferences["calculator_preferences"], into: %{} do
        {String.to_existing_atom(key), value}
      end

    amount = order |> calculator.compute(params) |> Decimal.mult(-1)
    params = set_adjustment_params(order, promotion, action, amount)

    case PromotionAdjustment.create(params) do
      {:ok, _data} ->
        true

      {:error, _data} ->
        false
    end
  end

  def action_name() do
    @name
  end

  ####################### Private Functions #####################

  defp set_adjustment_params(order, promotion, action, amount) do
    %{
      order: order,
      promotion: promotion,
      promotion_action: action,
      amount: amount,
      adjustable_type: :order,
      adjustable_id: order.id
    }
  end
end
