defmodule AdminApp.Promotion.CalculatorContext do
  @moduledoc false

  def preferences(calculator, params) do
    changeset = calculator.changeset(struct!(calculator), %{})

    data =
      changeset.types
      |> Stream.filter(fn {_data, type} -> type != :binary_id end)
      |> Enum.map(fn {data, type} ->
        %{key: data, type: get_data_type(type), value: params[to_string(data)]}
      end)

    %{name: calculator, data: data}
  end

  def get_data_type(:decimal) do
    "input"
  end
end
