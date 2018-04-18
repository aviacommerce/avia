defmodule Snitch.Tools.Money do
  @moduledoc """
  Some (weak) helpers to work with zeroes and `Money.t`.
  """

  @error_msg "default currency not set"

  @doc """
  Returns the zero `Money.t` with `currency`.

  If `currency` is not passed,
  * attempts to fetch default currency from application config.
  * if default currency is not set, returns a `{:error, #{@error_msg}}` tuple.

  ## Note
  Makes use of `Money.new/2` and this function won't `raise` unless application is
  not configured properly.
  """
  @spec zero(atom) :: Money.t() | {:error, term}
  def zero(currency \\ nil)

  def zero(nil) do
    {:ok, config_app} = Application.fetch_env(:snitch_core, :core_config_app)
    {:ok, defaults} = Application.fetch_env(config_app, :defaults)

    case Keyword.fetch(defaults, :currency) do
      :error -> {:error, {RuntimeError, @error_msg}}
      {:ok, default_currency} -> Money.new(0, default_currency)
    end
  end

  def zero(currency) when is_atom(currency) or is_binary(currency) do
    Money.new(0, currency)
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
    {:ok, config_app} = Application.fetch_env(:snitch_core, :core_config_app)
    {:ok, defaults} = Application.fetch_env(config_app, :defaults)

    case Keyword.fetch(defaults, :currency) do
      :error -> raise(RuntimeError, @error_msg)
      {:ok, default_currency} -> Money.new!(0, default_currency)
    end
  end

  def zero!(currency) when is_atom(currency) or is_binary(currency) do
    Money.new!(0, currency)
  end
end
