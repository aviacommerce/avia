defmodule AdminAppWeb.Exporter.Product do
  @moduledoc """
  Data export module for Product.
  """
  alias AdminAppWeb.Exporter
  alias Snitch.Data.Model.Product, as: ProductModel
  alias Snitch.Data.Schema.Product, as: ProductSchema
  import Ecto.Query

  @columns ~w(id name product_type slug state max_retail_price selling_price variant_count taxon_name weight height depth store theme_id is_active)a
  @preloads ~w(variants taxon shipping_category options brand theme)a

  def csv_exporter(user) do
    query =
      from(u in ProductSchema,
        preload: ^@preloads
      )

    Exporter.csv_exporter(user, "product", query, @columns)
  end

  def xlsx_exporter(user) do
    data_list = ProductModel.get_all_with_preloads(@preloads)
    Exporter.xlsx_exporter(user, "product", data_list, @columns)
  end

  defp get_product_type(product) do
    case ProductModel.is_parent_product(to_string(product.id)) do
      true ->
        "variable"

      false ->
        if ProductModel.is_child_product(product), do: "variant", else: "simple"
    end
  end

  def parse_line(%ProductSchema{} = product) do
    product
    |> Map.from_struct()
    |> Map.put(:product_type, get_product_type(product))
    |> Map.put(:taxon_name, product.taxon.name)
    |> Map.put(:variant_count, length(product.variants))
  end
end
