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
          add_error(changeset, key, "must be equal or greater than 0", validation: :number)
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

  @doc """
  Runs validations for embedded data and returns a changeset.

  Takes as input a `changeset`, `module` and `key`.

  Runs validations for the target embedded data by using the supplied `module`
  name under the module_key. The module_key can be different for different models.

  The module should implement a changeset function inorder for this to
  work. The `key` is used for identifying the type to which the data or in case
  of error an error, has to be added.

  ## See
  `Snitch.Data.Schema.PromotionAction`
  """
  @spec validate_embedded_data(changeset :: Ecto.Changeset.t(), module :: atom(), key :: atom) ::
          Ecto.Changeset.t()

  def validate_embedded_data(%Ecto.Changeset{valid?: true} = changeset, module_key, key) do
    with {:ok, preferences} <- fetch_change(changeset, key),
         {:ok, module_key} <- fetch_change(changeset, module_key) do
      preference_changeset = module_key.changeset(struct(module_key), preferences)
      add_preferences_change(preference_changeset, changeset, key)
    else
      :error ->
        changeset

      {:error, message} ->
        add_error(changeset, module_key, message)
    end
  end

  def validate_embedded_data(changeset, _module_key, _key), do: changeset

  defp add_preferences_change(%Ecto.Changeset{valid?: true} = embed_changeset, changeset, key) do
    data = embed_changeset.changes
    put_change(changeset, key, data)
  end

  defp add_preferences_change(pref_changeset, changeset, key) do
    additional_info =
      pref_changeset
      |> traverse_errors(fn {msg, opts} ->
        Enum.reduce(opts, msg, fn {key, value}, acc ->
          String.replace(acc, "%{#{key}}", to_string(value))
        end)
      end)

    add_error(changeset, key, "invalid_preferences", additional_info)
  end
end
