defmodule AdminAppWeb.Helpers do
  import Ecto.Changeset

  @months ["Jan", "Feb", "Mar", "Apr", "May", "June", "July", "Aug", "Sept", "Oct", "Nov", "Dec"]

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
    Enum.at(@months, month_number - 1)
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

  def build_export_query(user, batch_size \\ 500) do
    columns = ~w(id number special_instructions inserted_at updated_at user_id billing_address shipping_address state)

    query = """
      COPY (
        SELECT #{Enum.join(columns, ",")}
        FROM snitch_orders
        WHERE archived = false
        AND user_id = #{user.id}
      ) to STDOUT WITH CSV DELIMITER ',';
    """

    csv_header = [Enum.join(columns, ","), "\n"]

    Ecto.Adapters.SQL.stream(Repo, query, [], max_rows: batch_size)
    |> Stream.map(&(&1.rows))
    |> (fn stream -> Stream.concat(csv_header, stream) end).()
  end

end
