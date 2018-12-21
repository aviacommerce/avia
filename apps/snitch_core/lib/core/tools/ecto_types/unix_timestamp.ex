defmodule Snitch.Tools.EctoType.UnixTimestamp do
  @moduledoc """
  Creates a custom type for unix timestamp
  """

  @behaviour Ecto.Type
  alias Ecto.Type

  def type, do: :utc_datetime

  def cast(timestamp) when is_integer(timestamp) do
    {:ok, timestamp}
  end

  def cast(_), do: :error

  def dump(value) do
    {:ok, date} = DateTime.from_unix(value)
    Type.dump(:utc_datetime, date)
  end

  def load(value) do
    {:ok, date} = Type.load(:utc_datetime, value)
    {:ok, DateTime.to_unix(date)}
  end
end
