defmodule Snitch.Tools.Validations do
  @moduledoc """
  A bunch of data validations for `Ecto.Changeset`.

  ## Note

  All validations in this module are check ONLY the value present under the
  `:changes` key in the `Ecto.Changeset.t()`.

  The validations are non-strict, and will not complain if the key is not
  present under `:changes`.
  """

  import Ecto.Changeset

  @doc """
  Validates that the amount (of type `Money.t`) under the `key` in `changeset`
  is non-negative.
  """
  @spec validate_amount(Ecto.Changeset.t(), atom) :: Ecto.Changeset.t()
  def validate_amount(%Ecto.Changeset{} = changeset, key) when is_atom(key) do
    case fetch_change(changeset, key) do
      {:ok, %Money{amount: amount}} ->
        if Decimal.cmp(Decimal.reduce(amount), Decimal.new(0)) == :lt do
          add_error(changeset, key, "must be greater than 0", validation: :number)
        else
          changeset
        end

      :error ->
        changeset
    end
  end

  @doc """
  Validates that the given date (of type `DateTime.t`) under the `key` in
  `changeset` is in the future wrt. `DateTime.utc_now/0`.
  """
  @spec validate_future_date(Ecto.Changeset.t(), atom) :: Ecto.Changeset.t()
  def validate_future_date(%Ecto.Changeset{valid?: true} = changeset, key)
      when is_atom(key) do
    case fetch_change(changeset, key) do
      {:ok, date} ->
        current_time = DateTime.utc_now()

        if DateTime.compare(date, current_time) == :gt do
          changeset
        else
          add_error(changeset, key, "date should be in future", validation: :number)
        end

      :error ->
        changeset
    end
  end

  def validate_future_date(changeset, _), do: changeset
end
