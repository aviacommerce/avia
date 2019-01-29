defmodule AdminAppWeb.ShippingPolicyController do
  use AdminAppWeb, :controller

  import Ecto.Query

  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias Snitch.Data.Schema.ShippingCategory
  alias Snitch.Data.Model.ShippingCategory, as: ScModel

  def new(conn, _params) do
    shipping_category =
      ShippingCategory
      |> order_by([sc], asc: sc.name)
      |> Repo.all()
      |> List.first()

    {:ok, shipping_category} = ScModel.get_with_rules(shipping_category.id)

    render(conn, "index.html",
      shipping_rules: shipping_category.shipping_rules,
      shipping_category: shipping_category
    )
  end

  def edit(conn, %{"id" => id}) do
    case ScModel.get_with_rules(id) do
      {:error, _} ->
        conn
        |> put_flash(:error, "Not found")
        |> redirect(to: shipping_policy_path(conn, :new))

      {:ok, category} ->
        render(conn, "edit.html",
          shipping_rules: category.shipping_rules,
          shipping_category: category
        )
    end
  end

  def update(conn, %{"id" => id, "shipping_policy" => shipping_policy}) do
    update_params = shipping_category_params(id, shipping_policy)
    {:ok, category} = ScModel.get_with_rules(update_params.id)

    case ScModel.update(update_params, category) do
      {:ok, category} ->
        conn
        |> put_flash(:info, "Shipping Category updated with rules!")
        |> redirect(to: shipping_policy_path(conn, :edit, category.id))

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Some error occured")
        |> redirect(to: shipping_policy_path(conn, :edit, category.id))
    end
  end

  def shipping_category_params(id, policy) do
    rules = Map.values(policy) |> shipping_rules_manifest()

    %{
      id: String.to_integer(id),
      shipping_rules: rules
    }
  end

  def shipping_rules_manifest(rules) do
    Enum.map(rules, fn rule ->
      if Map.has_key?(rule, "active?") do
        rule
      else
        Map.put(rule, "active?", "false")
      end
    end)
  end
end
