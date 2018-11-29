defmodule Snitch.Tools.Money do
  @moduledoc """
  Some (weak) helpers to work with zeroes and `Money.t`.
  """
  alias Snitch.Data.Model.GeneralConfiguration, as: GCModel

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
    currency = GCModel.fetch_currency()
    Money.zero(currency)
  end

  def zero(currency) when is_atom(currency) or is_binary(currency) do
    Money.zero(currency)
  end

  @doc """
  Returns the zero `Money.t` with `currency`.

  If `currency` is not passed,
  * attempts to fetch default currency from the general settings.

  ## Note
  Makes use of `Money.new!/2` and this function can `raise`.
  """
  @spec zero!(atom) :: Money.t()
  def zero!(currency \\ nil)

  def zero!(nil) do
    currency = GCModel.fetch_currency()
    Money.zero(currency)
  end

  def zero!(currency) when is_atom(currency) or is_binary(currency) do
    Money.new!(0, currency)
  end
end
