defmodule AdminAppWeb.PaymentMethodController do
  use AdminAppWeb, :controller

  alias AdminAppWeb.PaymentMethodView
  alias Snitch.Data.Model.PaymentMethod
  alias Snitch.Data.Schema.PaymentMethod, as: PaymentMethodSchema
  import Phoenix.View, only: [render_to_string: 3]

  def index(conn, _params) do
    payment_methods = PaymentMethod.get_all()
    render(conn, "index.html", payment_methods: payment_methods)
  end

  def new(conn, _params) do
    changeset = PaymentMethodSchema.create_changeset(%PaymentMethodSchema{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, params) do
    updated_params = handle_payment_code(params["payment_method"])

    case PaymentMethod.create(updated_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Payment Method created!")
        |> redirect(to: payment_method_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Sorry, there were some errors!")
        |> render("new.html", changeset: %{changeset | action: :insert})
    end
  end

  def delete(conn, %{"id" => id}) do
    id = String.to_integer(id)

    case PaymentMethod.delete(id) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Deleted successfully!")
        |> redirect(to: payment_method_path(conn, :index))

      {:error, _} ->
        conn
        |> put_flash(:error, "not found")
        |> redirect(to: payment_method_path(conn, :index))
    end
  end

  def edit(conn, %{"id" => id}) do
    payment = PaymentMethod.get(String.to_integer(id))

    case payment do
      nil ->
        conn
        |> put_flash(:error, "Sorry method not found")
        |> redirect(to: payment_method_path(conn, :index))

      payment_method ->
        changeset = PaymentMethodSchema.update_changeset(payment_method, %{})
        render(conn, "edit.html", changeset: changeset, payment_method: payment_method)
    end
  end

  def update(conn, %{"id" => id, "payment_method" => params}) do
    update_params = handle_payment_code(params)
    payment_method = PaymentMethod.get(String.to_integer(id))

    case PaymentMethod.update(update_params, payment_method) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Updated Successfully!")
        |> redirect(to: payment_method_path(conn, :index))

      {:error, changeset} ->
        render(
          conn,
          "edit.html",
          changeset: %{changeset | action: :update},
          payment_method: payment_method
        )
    end
  end

  def payment_preferences(conn, %{"provider" => provider}) do
    provider = String.to_atom(provider)

    credentials =
      provider.preferences()
      |> Enum.into(%{}, fn credential -> {credential, ""} end)

    html =
      render_to_string(
        PaymentMethodView,
        "preferences_input.html",
        credentials: credentials
      )

    conn
    |> put_status(200)
    |> json(%{html: html})
  end

  ################## Private Functions ##################
  defp handle_payment_code(%{"provider" => provider} = params) do
    provider = String.to_existing_atom(provider)
    code = provider.payment_code

    params
    |> Map.put("provider", provider)
    |> Map.put("code", code)
  end

  defp handle_payment_code(params), do: params
end
