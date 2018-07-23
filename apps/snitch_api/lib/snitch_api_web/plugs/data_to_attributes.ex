defmodule SnitchApiWeb.Plug.DataToAttributes do
  import Inflex, only: [pluralize: 1]

  @moduledoc ~S"""
  Converts params in the JSON api format into flat params convient for
  changeset casting.
  For base parameters, this is done using `JaSerializer.Params.to_attributes/1`
  For included records, this is done using custom code.
  """

  alias Plug.Conn

  @spec init(Keyword.t()) :: Keyword.t()
  def init(opts), do: opts

  @spec call(Conn.t(), Keyword.t()) :: Plug.Conn.t()
  def call(%Conn{params: %{} = params} = conn, opts \\ []) do
    attributes =
      params
      |> Map.delete("data")
      |> Map.delete("included")
      |> Map.merge(params |> parse_data())
      |> Map.merge(params |> parse_included(opts))

    conn |> Map.put(:params, attributes)
  end

  @spec parse_data(map) :: map
  defp parse_data(%{"data" => data}), do: data |> JaSerializer.Params.to_attributes()
  defp parse_data(%{}), do: %{}

  @spec parse_included(map, Keyword.t()) :: map
  defp parse_included(%{"included" => included}, opts) do
    included
    |> Enum.reduce(%{}, fn %{"data" => %{"type" => type}} = params, parsed ->
      attributes = params |> parse_data()

      if opts |> Keyword.get(:includes_many, []) |> Enum.member?(type) do
        # this is an explicitly specified has_many,
        # update existing data by adding new record
        pluralized_type = type |> Inflex.pluralize()

        parsed
        |> Map.update(pluralized_type, [attributes], fn data ->
          data ++ [attributes]
        end)
      else
        # this is a belongs to, put a new submap into payload
        parsed |> Map.put(type, attributes)
      end
    end)
  end

  defp parse_included(%{}, _opts), do: %{}
end
