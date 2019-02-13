defmodule AdminAppWeb.Tax.TaxRateController do
  use AdminAppWeb, :controller
  alias Snitch.Data.Model.{TaxRate, TaxClass}
  alias Snitch.Data.Schema.TaxRate, as: TaxRateSchema
  alias Snitch.Data.Schema.TaxRateClassValue

  plug(:put_layout, {AdminAppWeb.Tax.TaxZoneView, "tax_zone_layout.html"} when action in [:index])

  def index(conn, %{"tax_zone_id" => tax_zone_id}) do
    tax_rates = TaxRate.get_all_by_tax_zone(tax_zone_id)
    render(conn, "index.html", tax_rates: tax_rates, tax_zone_id: tax_zone_id)
  end

  def new(conn, %{"tax_zone_id" => tax_zone_id}) do
    changeset =
      TaxRateSchema.create_changeset(
        %TaxRateSchema{tax_rate_class_values: rate_values_struct()},
        %{}
      )

    render(conn, "new.html", changeset: changeset, tax_zone_id: tax_zone_id)
  end

  def create(conn, %{"tax_rate" => params, "tax_zone_id" => tax_zone_id}) do
    with {:ok, _tax_rate} <- TaxRate.create(params) do
      redirect(conn, to: tax_zone_tax_rate_path(conn, :index, tax_zone_id))
    else
      {:error, changeset} ->
        render(conn, "new.html",
          changeset: %{changeset | action: :insert},
          tax_zone_id: tax_zone_id
        )
    end
  end

  def edit(conn, %{"id" => id, "tax_zone_id" => tax_zone_id}) do
    with {:ok, tax_rate} <- TaxRate.get(id) do
      changeset = TaxRateSchema.update_changeset(tax_rate, %{})

      render(conn, "edit.html", changeset: changeset, tax_rate: tax_rate, tax_zone_id: tax_zone_id)
    else
      {:error, _} ->
        conn
        |> put_flash(:error, "tax zone not found")

        redirect(conn, to: tax_zone_tax_rate_path(conn, :index, tax_zone_id))
    end
  end

  def update(conn, %{"id" => id, "tax_zone_id" => tax_zone_id, "tax_rate" => params}) do
    tax_rate = id |> TaxRate.get() |> get(conn)

    with {:ok, _config} <- TaxRate.update(tax_rate, params) do
      redirect(conn, to: tax_zone_tax_rate_path(conn, :index, tax_zone_id))
    else
      {:error, changeset} ->
        render(conn, "edit.html",
          changeset: %{changeset | action: :update},
          tax_rate: tax_rate,
          tax_zone_id: tax_zone_id
        )
    end
  end

  def delete(conn, %{"id" => id, "tax_zone_id" => tax_zone_id}) do
    with {:ok, _data} <- id |> String.to_integer() |> TaxRate.delete() do
      conn
      |> put_flash(:info, "tax zone deleted")
      |> redirect(to: tax_zone_tax_rate_path(conn, :index, tax_zone_id))
    else
      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> redirect(to: tax_zone_tax_rate_path(conn, :index, tax_zone_id))
    end
  end

  defp rate_values_struct() do
    tax_classes = TaxClass.get_all()

    Enum.map(tax_classes, fn class ->
      %TaxRateClassValue{
        tax_class_id: class.id,
        tax_class: class
      }
    end)
  end

  defp get({:ok, config}, _conn), do: config

  defp get({:error, message}, conn) do
    conn
    |> put_flash(:error, message)
    |> redirect(to: tax_zone_path(conn, :index))
  end
end
