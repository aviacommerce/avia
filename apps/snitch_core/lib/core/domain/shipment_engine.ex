defmodule Snitch.Domain.ShipmentEngine do
  @moduledoc """
  Finds the optimal shipment for a given order.

  `ShipmentEngine` models the problem as a [Constraint Satisfaction
  Problem][csp] and find the optimal `shipment` subject to the following
  constraints:

  1. Two (or more) `packages` cannot fulfill the same `lineitem`.
  2. Selected `packages` together fulfill the entire `order`.

  Returns a shipment, which is a list of `packages`.
  In case we are unable to find such a shipment, the empty `list` is returned.

  ## Limitations and future work

  Constraints that could be added in future:
  * prefer packages that are "on-hand" over backorder packages.
  * prefer shorter shipping distance (analogous to shipping time)
  * prefer smaller shipping cost (to user/store owner)

  [csp]: https://en.wikipedia.org/wiki/Constraint_Satisfaction_Problem
  """

  use Snitch.Domain

  alias Aruspex.Problem
  alias Aruspex.Strategy.SimulatedAnnealing
  alias Snitch.Data.Schema.Order

  @domain [true, false]

  @doc """
  Returns the optimal shipment from the `packages` fulfilling the `order`.

  The CSP is modelled as a graph of packages, where 2 packages are linked by an
  edge if they include the same line-item.

  Uses [Simulated Annealing][sa] to find the optimal shipment, see
  `Aruspex.Strategy.SimulatedAnnealing`. Note that this technique is
  probabilistic and [AC-3][ac3] should replace it.

  [sa]: https://en.wikipedia.org/wiki/Simulated_annealing
  [ac3]: https://en.wikipedia.org/wiki/AC-3_algorithm
  """
  @spec run(list, Order.t()) :: list
  def run([], _), do: []

  def run(packages, %Order{} = order) when is_list(packages) do
    packages_with_id = append_keys(packages)
    edges = create_csp(packages_with_id)

    vars =
      Enum.reduce(packages_with_id, [], fn p, acc ->
        [p.id | acc]
      end)

    item_var_map = item_var_mapping(packages_with_id)

    problem = Problem.new()

    for var <- vars, do: Problem.add_variable(problem, var, @domain)

    binary_constraint(problem, edges)
    summation_constraint(problem, vars, item_var_map, Repo.preload(order, [:line_items]))

    result =
      problem
      |> SimulatedAnnealing.set_strategy()
      |> Enum.take(1)

    bindings = variable_assignment(result)
    filter_packages(item_var_map, bindings)
  end

  defp variable_assignment([]), do: []

  defp variable_assignment([result]) do
    Enum.reject(result.binding, fn
      {{:hidden, _, _}, _} -> true
      _ -> false
    end)
  end

  defp filter_packages(packages, bindings) do
    Enum.reduce(bindings, [], fn
      {id, true}, acc -> [packages[id] | acc]
      {_, false}, acc -> acc
    end)
  end

  defp binary_constraint(problem, edges) do
    Enum.map(edges, fn {x, y} ->
      Problem.post(problem, x.id, y.id, &(not (&1 and &2)))
    end)
  end

  defp summation_constraint(problem, vars, item_var_map, order) do
    Problem.post(problem, vars, fn values ->
      item_count =
        vars
        |> Stream.zip(values)
        |> Enum.reduce(0, fn
          {var, true}, acc -> length(item_var_map[var].items) + acc
          {_, false}, acc -> acc
        end)

      item_count == length(order.line_items)
    end)
  end

  defp item_var_mapping(packages) do
    Enum.map(packages, fn pkg ->
      {pkg.id, pkg}
    end)
  end

  defp create_csp(packages) do
    packages
    |> create_edges()
    |> find_unique_edges()
  end

  defp append_keys(packages) do
    packages
    |> Stream.with_index(1)
    |> Enum.map(fn {package, index} ->
      Map.put(package, :id, String.to_atom("p#{index}"))
    end)
  end

  defp create_edges(packages) do
    for package1 <- packages,
        package2 <- packages,
        package1 != package2,
        not MapSet.disjoint?(package1.variants, package2.variants) do
      {package1, package2}
    end
  end

  def find_unique_edges(package_edges) do
    Enum.reduce(package_edges, [], fn {package1, package2}, acc ->
      case Enum.member?(acc, {package1, package2}) or Enum.member?(acc, {package2, package1}) do
        true -> acc
        false -> [{package1, package2} | acc]
      end
    end)
  end
end
