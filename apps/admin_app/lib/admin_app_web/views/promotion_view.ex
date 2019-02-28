defmodule AdminAppWeb.PromotionView do
  @moduledoc false

  use AdminAppWeb, :view
  alias AdminApp.Promotion.ActionContext
  alias AdminApp.Promotion.RuleContext
  alias Ecto.Changeset
  alias Snitch.Data.Schema.{Promotion, PromotionAction, PromotionRule}

  def render("index.json", %{promotions: promotions}) do
    %{data: render_many(promotions, __MODULE__, "promo.json")}
  end

  def render("list.json", %{data: data}) do
    %{
      data: data
    }
  end

  def render("promo.json", %{promotion: promo}) do
    %{
      id: promo.id,
      name: promo.name,
      code: promo.code,
      starts_at: promo.starts_at,
      expires_at: promo.expires_at,
      usage_count: promo.current_usage_count,
      usage_limit: promo.usage_limit
    }
  end

  def render("pref.json", %{data: data}) do
    %{
      data: data
    }
  end

  def render("promotion.json", %{promotion: promotion}) do
    %{
      attributes: %{
        id: promotion.id,
        name: promotion.name,
        code: promotion.code,
        starts_at: promotion.starts_at,
        expires_at: promotion.expires_at,
        description: promotion.description,
        usage_count: promotion.current_usage_count,
        usage_limit: promotion.usage_limit,
        match_policy: promotion.match_policy,
        active?: promotion.active?,
        archived_at: promotion.archived_at
      },
      rules: render_many(promotion.rules, __MODULE__, "rule.json", as: :rule),
      actions: render_many(promotion.actions, __MODULE__, "action.json", as: :action)
    }
  end

  def render("rule.json", %{rule: rule}) do
    RuleContext.rule_preferences(rule.module, rule.preferences)
  end

  def render("action.json", %{action: action}) do
    ActionContext.action_preferences(action.module, action.preferences)
  end

  def render("changeset_error.json", %{changeset: changeset}) do
    errors =
      Changeset.traverse_errors(changeset, fn
        %Ecto.Changeset{data: %Promotion{}}, _field, {msg, opts} ->
          %{message: msg, errors: Enum.into(opts, %{})}

        %Ecto.Changeset{data: %PromotionAction{}, changes: changes}, _field, {msg, opts} ->
          %{name: changes.name, message: msg, errors: opts}

        %Ecto.Changeset{data: %PromotionRule{}, changes: changes}, _field, {msg, opts} ->
          %{name: changes.name, message: msg, errors: opts}
      end)

    %{errors: errors}
  end

  def render("error_message.json", %{message: message}) do
    %{
      error: %{
        message: message
      }
    }
  end
end
