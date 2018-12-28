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

    {collection, page, format_aggregations(aggregations), total}
  end

  defp convert_to_elastic_query(params) do
    {offset, limit} = extract_page_params(params)

    query = %{
      "sort" => %{},
      "query" => %{
        "bool" => %{
          "must" =>
            tenant_query() ++ generate_query_from_filter_string(params) ++ match_keywords(params)
        }
      },
      "aggs" => aggregate_query()
    }

    query
    |> sorting_query(params)
    |> paginate(offset, limit)
  end

  defp generate_query_from_filter_string(%{"f" => ""}), do: []

  defp generate_query_from_filter_string(%{"f" => f}) do
    f
    |> String.splitter("::")
    |> Stream.flat_map(fn filter_string ->
      [filter, values] = String.split(filter_string, ":")
      primary_filter_query({filter, String.split(values, ",")})
    end)
    |> Enum.into([])
  end

  defp generate_query_from_filter_string(_), do: []

  defp primary_filter_query({_, []}), do: []
  defp primary_filter_query({_, [""]}), do: []

  defp primary_filter_query({filter, values}) do
    [
      %{
        "nested" => %{
          "path" => "filters",
          "query" => %{
            "bool" => %{
              "filter" => [
                %{
                  "term" => %{
                    "filters.id" => filter
                  }
                },
                %{
                  "terms" => %{
                    "filters.value" => values
                  }
                }
              ]
            }
          }
        }
      }
    ]
  end

  defp aggregate_query() do
    %{
      "filters" => %{
        "nested" => %{
          "path" => "filters"
        },
        "aggs" => %{
          "aggregations" => %{
            "terms" => %{
              "script" => "doc['filters.id'].value + '|' + doc['filters.value'].value"
            }
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

  defp match_keywords(%{"q" => ""}), do: []

  defp match_keywords(%{"q" => query}) do
    [
      %{
        "match" => %{
          "name" => %{
            "query" => query,
            "operator" => "and",
            "fuzziness" => "AUTO"
          }
        }
      }
    ]
  end

  defp match_keywords(_), do: []

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

  defp get_base_url(conn) do
    case conn.req_headers
         |> Enum.filter(fn {x, _y} -> x == "host" end)
         |> Enum.at(0) do
      {_, base_url} -> base_url
      _ -> ""
    end
  end

  defp extract_page_params(%{"rows" => limit, "o" => offset}),
    do: {String.to_integer(offset), String.to_integer(limit)}

  defp extract_page_params(_), do: {0, Application.get_env(:ja_serializer, :page_size, 2)}

  # Generates the pagination links like `prev` `self` `next` `last` using
  # data-collection and params-page
  defp gen_page_links(total, params, conn) do
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

  # This develops the query according to the page parameters.
  defp paginate(query, offset, limit) do
    Map.merge(
      query,
      %{
        "from" => offset,
        "size" => limit
      }
    )
  end

  defp format_aggregations(aggregations) do
    %{
      "filters" => %{"aggregations" => %{"buckets" => filters}}
    } = aggregations

    %{
      "filters" => format_id_value_key_aggs(filters)
    }
  end

  defp format_id_value_key_aggs(filters) do
    filters
    |> Enum.reduce(
      %{},
      fn %{"key" => key, "doc_count" => count}, acc ->
        [id, value] = String.split(key, "|")

        Map.merge(acc, %{
          id => %{
            "id" => id,
            "filterValues" => [
              %{
                "id" => value,
                "count" => count,
                "meta" => ""
              }
              | (acc[id] && acc[id]["filterValues"]) || []
            ]
          }
        })
      end
    )
    |> Map.values()
  end
end
