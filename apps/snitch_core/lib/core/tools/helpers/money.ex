defmodule Snitch.Tools.Money do
  @moduledoc """
  Some (weak) helpers to work with zeroes and `Money.t`.
  """

  @defaults Application.get_env(:snitch_core, :defaults_module)

  @doc """
  Returns the zero `Money.t` with `currency`.

  If `currency` is not passed,
  * attempts to fetch default currency from application config.
  * if default currency is not set, returns a `{:error, string}` tuple.

  ## Note
  Makes use of `Money.new!/2` and `Money.zero/1` and this function won't `raise`
  unless application is not configured properly.
  """
  @spec zero(atom) :: Money.t() | {:error, term}
  def zero(currency \\ nil)

  def zero(nil) do
    case @defaults.fetch(:currency) do
      {:ok, default_currency} -> Money.zero(default_currency)
      error -> error
    end
  end

  def zero(currency) when is_atom(currency) or is_binary(currency) do
    Money.zero(currency)
  end

  @doc """
  Returns the zero `Money.t` with `currency`.

  If `currency` is not passed,
  * attempts to fetch default currency from application config.
  * if default currency is not set, raises a `Money.UnkownCurrencyError`

  ## Note
  Makes use of `Money.new!/2` and this function can `raise`.
  """
  @spec zero!(atom) :: Money.t()
  def zero!(currency \\ nil)

  def zero!(nil) do
    case @defaults.fetch(:currency) do
      {:ok, default_currency} -> Money.new!(0, default_currency)
      {:error, msg} -> raise(RuntimeError, msg)
    end
  end

  def zero!(currency) when is_atom(currency) or is_binary(currency) do
    Money.new!(0, currency)
  end
end
