defmodule Snitch.Tools.ElasticSearch.ProductSearch do
  @moduledoc """
  Product Search using elasticsearch
  """
  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias Snitch.Data.Schema.Product

  import Snitch.Tools.ElasticSearch.ProductStore, only: [search_products: 1]
  import Ecto.Query

  def run(conn, params) do
    %{
      "hits" => %{
        "hits" => collection,
        "total" => total
      },
      "aggregations" => aggregations
    } =
      params
      |> convert_to_elastic_query
      |> search_products
      |> Map.put_new("aggregations", %{})

    page = gen_page_links(total, params, conn)

    {collection, page, aggregations, total}
  end

  @doc """
  Develops the query based on the giver params..
  This supports the following api calling...
  - /products
  - /products/slug
  - /products?sort=price-asc-rank
  - /products?sort=price-desc-rank
  - /products?sort=date
  - /products?sort=avg_rating
  - /products?sort=A-Z&filter[name]=Hill's
  - /products?sort=A-Z&filter[name]=Hill's&page[limit]=2&page[offset]=2
  - /products?sort=A-Z&filter[name]=Hill's&page[limit]=2
  """
  def convert_to_elastic_query(params) do
    {number, size} = extract_page_params(params)

    query = %{
      "sort" => %{},
      "query" => %{
        "bool" => %{
          "must" =>
            (tenant_query() ++ match_keywords(params)) ++
              taxon_query(params) ++ brand_query(params)
        }
      },
      "aggs" => aggregate_query(params)
    }

    query
    |> sorting_query(params)
    |> paginate(number, size)
  end

  def aggregate_query(params) do
    %{
      "brand" => %{
        "terms" => %{
          "field" => "brand"
        }
      },
      "categories" => category_aggs(params),
      "options" => filter_opts_aggs(params)
    }
  end

  defp category_aggs(_params) do
    %{
      "nested" => %{
        "path" => "taxon_path"
      },
      "aggs" => %{
        "taxon" => %{
          "terms" => %{
            "script" => "doc['taxon_path.id'].value + '|' + doc['taxon_path.name'].value"
          }
        }
      }
    }
  end

  defp filter_opts_aggs(_params) do
    %{
      "nested" => %{
        "path" => "variants.options"
      },
      "aggs" => %{
        "option" => %{
          "terms" => %{
            "script" =>
              "doc['variants.options.name'].value + '|' + doc['variants.options.value'].value"
          }
        }
      }
    }
  end

  defp tenant_query() do
    [
      %{
        "term" => %{
          "tenant" => Repo.get_prefix()
        }
      }
    ]
  end

  defp match_keywords(%{"filter" => %{"name" => name}}) do
    [
      %{
        "match" => %{
          "name" => %{
            "query" => name,
            "operator" => "and",
            "fuzziness" => "AUTO"
          }
        }
      }
    ]
  end

  defp match_keywords(_), do: []

  defp taxon_query(%{"taxon" => taxon}) do
    [
      %{
        "nested" => %{
          "path" => "taxon_path",
          "query" => %{
            "bool" => %{
              "filter" => [
                %{
                  "match" => %{
                    "taxon_path.id" => taxon
                  }
                }
              ]
            }
          }
        }
      }
    ]
  end

  defp taxon_query(_), do: []

  defp brand_query(%{"product_brand" => brand}) do
    [
      %{
        "term" => %{
          "brand" => brand
        }
      }
    ]
  end

  defp brand_query(_), do: []

  defp sorting_query(query, params) do
    case params["sort"] do
      "price-desc-rank" ->
        %{query | "sort" => %{"selling_price.amount" => %{"order" => "desc"}}}

      "price-asc-rank" ->
        %{query | "sort" => %{"selling_price.amount" => %{"order" => "asc"}}}

      "date" ->
        %{query | "sort" => %{"updated_at" => %{"order" => "desc"}}}

      "avg_rating" ->
        %{
          query
          | "sort" => %{
              "rating_summary.average_rating" => %{
                "order" => "desc",
                "nested" => %{
                  "path" => "rating_summary"
                }
              }
            }
        }

      _ ->
        %{query | "sort" => %{"_score" => %{"order" => "desc"}}}
    end
  end

  def get_base_url(conn) do
    case conn.req_headers
         |> Enum.filter(fn {x, _y} -> x == "host" end)
         |> Enum.at(0) do
      {_, base_url} -> base_url
      _ -> ""
    end
  end

  @doc """
  This extracts the page parameters and converts to integer
  """
  def extract_page_params(params) do
    case params do
      %{"page" => page} ->
        {String.to_integer(page["offset"]), String.to_integer(page["limit"])}

      _ ->
        {1, Application.get_env(:ja_serializer, :page_size, 2)}
    end
  end

  @doc """
  Generates the pagination links like `prev` `self` `next` `last` using
  data-collection and params-page
  """
  def gen_page_links(total, params, conn) do
    {number, size} = extract_page_params(params)

    JaSerializer.Builder.PaginationLinks.build(
      %{
        number: number,
        size: size,
        total: div(total, size),
        base_url: "http://" <> get_base_url(conn) <> "/api/v1/products"
      },
      conn
    )
  end

  @doc """
  This develops the query according to the page parameters.
  """
  def paginate(query, page_number, size) do
    Map.merge(
      query,
      %{
        "from" => (page_number - 1) * size,
        "size" => size
      }
    )
  end
end
