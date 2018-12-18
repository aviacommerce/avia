defmodule Snitch.Data.Schema.PromotionAction.LineItemAction do
  @moduledoc """
  Models the actions to be applied for an `order`.
  """

  use Snitch.Data.Schema
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
