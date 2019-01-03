defmodule Snitch.Data.Model.PromotionHelper do
  @moduledoc """
  Exposes some helper functions for promotions.
  """

  @doc """
  Returns a list of promotion rules implemented.

  The returned list has the format
  [%{name: rule_name, module: module_implementing_it}]
  """
  def all_rules() do
    values = PromotionRuleEnum.__valid_values__()

    values
    |> Stream.filter(fn value -> is_atom(value) end)
    |> Enum.map(fn module ->
      %{
        name: module.rule_name,
        module: module
      }
    end)
  end

  @doc """
  Returns a list of promotion actions implemented.

  The returned list has the format
  [%{name: rule_name, module: module_implementing_it}]
  """
  def all_actions() do
    values = PromotionActionEnum.__valid_values__()

    values
    |> Stream.filter(fn value -> is_atom(value) end)
    |> Enum.map(fn module ->
      %{
        name: module.action_name,
        module: module
      }
    end)
  end

  def calculators() do
    values = ActionCalculators.__valid_values__()

    values
    |> Stream.filter(fn value -> is_atom(value) end)
    |> Enum.map(fn module ->
      %{
        name: get_name_from_module(module),
        module: module
      }
    end)
  end

  defp get_name_from_module(module) do
    module
    |> to_string()
    |> String.split(".")
    |> List.last()
  end
end
