defmodule SnitchApiWeb.ProductControllerTest do
  use SnitchApiWeb.ConnCase, async: true

  import Snitch.Factory

  alias Snitch.Data.Schema.Product
  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias Snitch.Tools.ElasticsearchCluster, as: ESCluster
  alias Elasticsearch.{Index, Cluster}
  alias Snitch.Tools.ElasticSearch.Product.Store, as: ProductStore

  setup %{conn: conn} do
    Elasticsearch.delete(ESCluster, "products_test")

    Index.create_from_file(
      ESCluster,
      "products_test",
      "test/support/settings/products.json"
    )

    conn =
      conn
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    {:ok, conn: conn, taxon: insert(:taxon)}
  end

  test "lists all products entries on index", %{conn: conn} do
    conn = get(conn, product_path(conn, :index))
    assert json_response(conn, 200)["data"]
  end

  test "shows chosen resource product", %{conn: conn, taxon: taxon} do
    product = insert(:product, state: "active", taxon: taxon)
    ProductStore.update_product_to_es(product)
    :timer.sleep(1000)
    conn = get(conn, product_path(conn, :show, product.slug))

    assert json_response(conn, 200)["data"] |> Map.take(["id", "type"]) == %{
             "id" => "#{product.id}",
             "type" => "product"
           }
  end

  test "Products, search contains name and pagination", %{conn: conn, taxon: taxon} do
    product1 = insert(:product, state: "active", taxon: taxon)
    product2 = insert(:product, state: "active", taxon: taxon)
    product3 = insert(:product, state: "active", taxon: taxon)
    Enum.map([product1, product2, product3], &ProductStore.update_product_to_es/1)
    :timer.sleep(1000)

    params = %{
      "q" => "product",
      "rows" => "50",
      "o" => "0"
    }

    conn = get(conn, product_path(conn, :index, params))

    response =
      json_response(conn, 200)["data"]
      |> Enum.count()

    assert response == 3
  end

  test "Products, sort by newly inserted", %{conn: conn, taxon: taxon} do
    product = insert(:product, state: "active", taxon: taxon)
    ProductStore.update_product_to_es(product)
    :timer.sleep(1000)

    params = %{
      "sort" => "date"
    }

    conn = get(conn, product_path(conn, :index, params))

    response =
      json_response(conn, 200)["data"]
      |> List.first()

    assert response["attributes"]["name"] == product.name
  end
end
