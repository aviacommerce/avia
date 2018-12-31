defmodule AdminAppWeb.Helpers do
  import Ecto.Changeset

  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias Snitch.Data.Schema.{Order, Product}

  def extract_changeset_data(changeset) do
    if changeset.valid?() do
      {:ok, Params.data(changeset)}
    else
      {:error, changeset}
    end
  end

  def extract_changeset_errors(changeset) do
    traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  @doc """
  Return the date in the format:
    HH:MIN, DAY, DATE, MONTH, YEAR
  """
  @spec format_date(NaiveDateTime.t()) :: String.t()
  def format_date(date) do
    to_string(date.hour) <>
      ":" <>
      to_string(date.minute) <>
      ", " <> to_string(date.day) <> " " <> month_name(date.month) <> ", " <> to_string(date.year)
  end

  def month_name(month_number) when month_number in 1..12 do
    Elixir.Timex.month_shortname(month_number)
  end

  @doc """
  Return the date in the params with the key or returns
  date of the day as recived from Date.utc_today(calendar \\ Calendar.ISO) in
  string format.
  """
  @spec get_date_from_params(map(), any()) :: any()
  def get_date_from_params(params, key) do
    today = Date.utc_today() |> Date.to_string()
    select_date(today, Map.get(params, key))
  end

  defp select_date(today, nil), do: today

  defp select_date(today, ""), do: today

  defp select_date(_today, date_from_params), do: date_from_params

  def date_today() do
    Date.utc_today()
    |> Date.to_string()
  end

  def date_days_before(days) do
    Date.utc_today()
    |> Date.add(-1 * days)
    |> Date.to_string()
  end
end
