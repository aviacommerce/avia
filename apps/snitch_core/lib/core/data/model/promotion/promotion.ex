defmodule Snitch.Data.Model.Promotion do
  @moduledoc """
  APIs for promotion.
  """

  @doc """
  Applies a coupon to the supplied order depending on some
  conditions.

  Returns {:ok, map} | {:error, map} depending on whether the coupon was
  applied or not.
  At present adjustments can happen for only one valid coupon at a time, multiple
  coupons application is not supported.
  """
  @spec apply(order :: Order.t(), coupon :: String.t()) ::
          {:ok, map}
          | {:error, map}
  def apply(order, coupon) do
  end

  def activate() do
  end

  defp process_adjustments() do
  end
end
