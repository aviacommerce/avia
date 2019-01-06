defmodule Snitch.Data.Model.Promotion.Applicability do
  @moduledoc """
  Exposes functions related to promotion level checks.
  """

  use Snitch.Data.Model
  alias Snitch.Data.Schema.Promotion

  @errors %{
    not_found: "promotion not found",
    inactive: "promotion is not active",
    expired: "promotion has expired"
  }

  @success %{
    promo_active: "promotion active",
    has_actions: "has actions"
  }

  @doc """
  Checks if a valid coupon exists for the supplied coupon_code.

  The function along with valid `code` name also checks if coupon is not
  `archived`.
  """
  @spec valid_coupon_check(String.t()) :: {:ok, Promotion.t()} | {:error, String.t()}
  def valid_coupon_check(coupon_code) do
    case Repo.get_by(Promotion, code: coupon_code, archived_at: 0) do
      nil ->
        {:error, @errors.not_found}

      promotion ->
        {:ok, promotion}
    end
  end

  def promotion_active(promotion) do
    if promotion.active? do
      {true, @success.promo_active}
    else
      {false, @errors.inactive}
    end
  end

  def promotion_actions_exist(promotion) do
    promotion = Repo.preload(promotion, :actions)

    case promotion.actions do
      [] ->
        {false, @errors.inactive}

      _ ->
        {true, @success.has_actions}
    end
  end

  @doc """
  Checks for `starts_at` date for promotion.

  If the `starts_at` is in past then `true` is returned otherwise, if `starts_at`
  is in future it means promotion has not started and not active is returned
  for the promotion.
  """
  def starts_at_check(promotion) do
    if DateTime.compare(DateTime.utc_now(), promotion.starts_at) == :gt do
      {true, @success.promo_active}
    else
      {false, @errors.inactive}
    end
  end

  @doc """
  Checks for `expires_at` date for the promotion.

  If `expires_at` is in past then the coupon has expired otherwise it is
  still active.
  """
  def expires_at_check(promotion) do
    if DateTime.compare(DateTime.utc_now(), promotion.expires_at) == :lt do
      {true, @success.promo_active}
    else
      {false, @errors.expired}
    end
  end

  @doc """
  Checks for `usage_limit` for the promotion.

  If usage limit reached returns {false, message} and coupon code expired
  otherwise returns {true, message}.

  ### Note
  In case the `usage_limit` property of promotion has been set to zero,
  it is being assumed that the store keeper wants the usage limit to be infinite.
  """
  def usage_limit_check(promotion) do
    if promotion.usage_limit == 0 do
      {true, @success.promo_active}
    else
      if promotion.usage_limit > promotion.current_usage_count do
        {true, @success.promo_active}
      else
        {false, @errors.expired}
      end
    end
  end
end
