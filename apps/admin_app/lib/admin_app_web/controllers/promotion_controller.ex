defmodule AdminAppWeb.PromotionController do
  use AdminAppWeb, :controller

  alias AdminApp.Promotion.ActionContext
  alias AdminApp.Promotion.CalculatorContext
  alias AdminApp.Promotion.RuleContext
  alias Snitch.Data.Model.Promotion
  alias Snitch.Data.Model.PromotionHelper

  def index(conn, _params) do
    promotions = Promotion.get_all()
    render(conn, "index.json", promotions: promotions)
  end

  def create(conn, %{"data" => data}) do
    with {:ok, promotion} <- Promotion.create(data) do
      promotion = Promotion.get(%{id: promotion.id})
      render(conn, "promotion.json", promotion: promotion)
    else
      {:error, changeset} ->
        conn
        |> put_status(422)
        |> render("changeset_error.json", changeset: changeset)
    end
  end

  def update(conn, %{"data" => data}) do
    id = String.to_integer(data["id"])

    with promotion when not is_nil(promotion) <- Promotion.get(%{id: id}),
         {:ok, promotion} <- Promotion.update(promotion, data) do
      render(conn, "promotion.json", promotion: promotion)
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(422)
        |> render("changeset_error.json", changeset: changeset)

      {:error, message} ->
        conn
        |> put_status(422)
        |> render("error_message.json", message: message)

      nil ->
        conn
        |> put_status(401)
        |> render(AdminAppWeb.ErrorView, "401.json")
    end
  end

  def edit(conn, %{"id" => id}) do
    with promotion when not is_nil(promotion) <- Promotion.get(%{id: id}) do
      render(conn, "promotion.json", promotion: promotion)
    else
      nil ->
        conn
        |> put_status(401)
        |> render(AdminAppWeb.ErrorView, "401.json")
    end
  end

  def delete(conn, %{"id" => id}) do
  end

  def rules(conn, _params) do
    rules = PromotionHelper.all_rules()
    render(conn, "list.json", data: rules)
  end

  def actions(conn, _params) do
    rules = PromotionHelper.all_rules()
    render(conn, "list.json", data: rules)
  end

  def calculators(conn, _params) do
    calculators = PromotionHelper.calculators()
    render(conn, "list.json", data: calculators)
  end

  def rule_preferences(conn, %{"rule" => rule}) do
    rule = String.to_existing_atom(rule)
    prefs = RuleContext.rule_preferences(rule)
    render(conn, "pref.json", data: prefs)
  end

  def action_preferences(conn, %{"action" => action}) do
    action = String.to_existing_atom(action)
    prefs = ActionContext.action_preferences(action)
    render(conn, "pref.json", data: prefs)
  end

  def calc_preferences(conn, %{"calculator" => calculator}) do
    calculator = String.to_existing_atom(calculator)
    prefs = CalculatorContext.preferences(calculator, %{})
    render(conn, "pref.json", data: prefs)
  end
end
