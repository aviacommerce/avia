defmodule Snitch.Tools.ElasticSearch.Product.Search do
  @moduledoc """
  Product Search using elasticsearch

  # TODO : NEEDS A FULL REFACTOR BY @pkrawat1
  # ===== !!!!!! DONOT MODIFY ME !!!!!! =====

  Architecture reference ( IN PROGRESS) : https://project-a.github.io/on-site-search-design-patterns-for-e-commerce/#index-pages-not-products
  Aggregation reference : https://stackoverflow.com/questions/41369749/elasticsearch-generic-facets-structure-calculating-aggregations-combined-wit

  """
  alias Snitch.Core.Tools.MultiTenancy.Repo

  import Snitch.Tools.ElasticSearch.Product.Store, only: [search_products: 1]

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
      |> Map.put_new("aggregations", generate_aggregations(params))

    page = gen_page_links(total, params, conn)
    {collection, page, format_aggregations(aggregations), total}
  end

  defp convert_to_elastic_query(params) do
    {offset, limit} = extract_page_params(params)

    query = %{
      "sort" => %{},
      "query" => filter_query(params)
    }

    query
    |> sorting_query(params)
    |> paginate(offset, limit)
  end

  defp filter_query(params) do
    %{
      "bool" => %{
        "must" =>
          tenant_query() ++
            generate_query_from_string_facet(params) ++
            generate_query_from_number_facet(params) ++ match_keywords(params)
      }
    }
  end

  defp generate_query_from_string_facet(%{"f" => ""}), do: []

  defp generate_query_from_string_facet(%{"f" => f}) do
    f
    |> String.splitter("::")
    |> Stream.flat_map(fn filter_string ->
      [filter, values] = String.split(filter_string, ":")
      string_facet_query({filter, String.split(values, ",")})
    end)
    |> Enum.into([])
  end

  defp generate_query_from_string_facet(_), do: []

  defp string_facet_query({_, []}), do: []
  defp string_facet_query({_, [""]}), do: []

  defp string_facet_query({"Category", values}) do
    [
      %{
        "nested" => %{
          "path" => "category",
          "query" => %{
            "bool" => %{
              "must" => %{
                "terms" => %{
                  "category.all_parents" => values
                }
              }
            }
          }
        }
      }
    ]
  end

  defp string_facet_query({filter, values}) do
    [
      %{
        "nested" => %{
          "path" => "string_facet",
          "query" => %{
            "bool" => %{
              "filter" => [
                %{
                  "term" => %{
                    "string_facet.id" => filter
                  }
                },
                %{
                  "terms" => %{
                    "string_facet.value" => values
                  }
                }
              ]
            }
          }
        }
      }
    ]
  end

  defp generate_query_from_number_facet(%{"rf" => ""}), do: []

  defp generate_query_from_number_facet(%{"rf" => rf}) do
    rf
    |> String.splitter("::")
    |> Stream.flat_map(fn filter_string ->
      [filter, values] = String.split(filter_string, ":")
      number_facet_query({filter, String.split(values, ",")})
    end)
    |> Enum.into([])
  end

  defp generate_query_from_number_facet(_), do: []

  defp number_facet_query({_, []}), do: []
  defp number_facet_query({_, [""]}), do: []

  defp number_facet_query({filter, [value | _]}) do
    [min, max] = String.split(value, " TO ")

    [
      %{
        "nested" => %{
          "path" => "number_facet",
          "query" => %{
            "bool" => %{
              "filter" => [
                %{
                  "term" => %{
                    "number_facet.id" => filter
                  }
                },
                %{
                  "range" => %{
                    "number_facet.value" => %{
                      "gte" => min,
                      "lte" => max
                    }
                  }
                }
              ]
            }
          }
        }
      }
    ]
  end

  defp generate_aggregations(params) do
    aggregation_query =
      Map.merge(
        %{
          "full_filter_aggs" => %{
            "filter" => filter_query(params),
            "aggs" => %{
              "category" => category_aggs_query(),
              "filters" => filters_aggs_query()
            }
          },
          "range_filters" => range_filters_aggs_query(params)
        },
        generate_string_facet_aggs_query(params)
      )

    %{
      "aggregations" => aggregations
    } =
      search_products(%{
        "size" => 0,
        "aggs" => aggregation_query
      })

    aggregations
  end

  defp generate_string_facet_aggs_query(%{"f" => ""}), do: %{}

  defp generate_string_facet_aggs_query(%{"f" => f} = params) do
    f
    |> String.splitter("::")
    |> Stream.map(fn filter_string ->
      [filter, values] = String.split(filter_string, ":")
      string_facet_aggs_query(filter, String.split(values, ","), params)
    end)
    # iex => [{"a", 1}, {"b", 1}, {}] |> Stream.filter(&!match?({}, &1)) |> Enum.into(%{})
    # iex => %{"a" => 1, "b" => 1}
    |> Stream.filter(&(!match?({}, &1)))
    |> Enum.into(%{})
  end

  defp generate_string_facet_aggs_query(_), do: %{}

  defp string_facet_aggs_query(_, [], _), do: {}
  defp string_facet_aggs_query(_, [""], _), do: {}

  defp string_facet_aggs_query("Category", _, params) do
    escaped_filter_param = escape_filter_from_params("Category", params)

    {
      "special_agg_Category",
      %{
        "filter" => filter_query(%{params | "f" => escaped_filter_param}),
        "aggs" => %{
          "special_agg_Category" => category_aggs_query()
        }
      }
    }
  end

  defp string_facet_aggs_query(filter, _, params) do
    escaped_filter_param = escape_filter_from_params(filter, params)

    {"special_agg_#{filter}",
     %{
       "filter" => filter_query(%{params | "f" => escaped_filter_param}),
       "aggs" => %{
         "special_agg_#{filter}" => %{
           "nested" => %{
             "path" => "string_facet"
           },
           "aggs" => %{
             "aggregation" => %{
               "filter" => %{
                 "match" => %{
                   "string_facet.id" => filter
                 }
               },
               "aggs" => %{
                 "aggregations" => %{
                   "terms" => %{
                     "size" => 1000,
                     "script" =>
                       "doc['string_facet.id'].value + '|' + doc['string_facet.value'].value"
                   }
                 }
               }
             }
           }
         }
       }
     }}
  end

  defp escape_filter_from_params(filter, %{"f" => f} = _params) do
    f
    |> String.splitter("::")
    |> Stream.filter(&(!match?([^filter, _], String.split(&1, ":"))))
    |> Enum.join("::")
  end

  defp category_aggs_query() do
    %{
      "nested" => %{
        "path" => "category"
      },
      "aggs" => %{
        "aggregations" => %{
          "terms" => %{
            "script" => "'Category|' + doc['category.direct_parent'].value"
          }
        }
      }
    }
  end

  defp filters_aggs_query() do
    %{
      "nested" => %{
        "path" => "string_facet"
      },
      "aggs" => %{
        "aggregations" => %{
          "terms" => %{
            "script" => "doc['string_facet.id'].value + '|' + doc['string_facet.value'].value"
          }
        }
      }
    }
  end

  defp range_filters_aggs_query(%{"rf" => _} = params) do
    %{
      "filter" => filter_query(%{params | "rf" => ""}),
      "aggs" => %{
        "range_filters" => %{
          "nested" => %{
            "path" => "number_facet"
          },
          "aggs" => %{
            "aggregations" => %{
              "terms" => %{
                "field" => "number_facet.id"
              },
              "aggs" => %{
                "facet_value" => %{
                  "stats" => %{
                    "field" => "number_facet.value"
                  }
                }
              }
            }
          }
        }
      }
    }
  end

  defp range_filters_aggs_query(params),
    do: params |> Map.put("rf", "") |> range_filters_aggs_query()

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
      "full_filter_aggs" => %{
        "category" => %{"aggregations" => %{"buckets" => category_buckets}},
        "filters" => %{"aggregations" => %{"buckets" => filter_buckets}}
      },
      "range_filters" => %{"range_filters" => %{"aggregations" => %{"buckets" => range_filters}}}
    } = aggregations

    filter_buckets =
      (category_buckets ++ filter_buckets) ++
        Enum.flat_map(aggregations, &format_special_string_facet_agg/1)

    %{
      "filters" => format_id_value_key_aggs(filter_buckets),
      "range_filters" => fomart_range_aggs(range_filters)
    }
  end

  defp format_id_value_key_aggs(buckets) do
    buckets
    |> Enum.map(fn %{"key" => key, "doc_count" => count} ->
      {key, count}
    end)
    |> Enum.into(%{})
    |> Enum.reduce(
      %{},
      fn {key, count}, acc ->
        [id, value] = String.split(key, "|")

        Map.merge(acc, %{
          id => %{
            "id" => id,
            "values" => [
              %{
                "id" => value,
                "count" => count,
                "meta" => ""
              }
              | (acc[id] && acc[id]["values"]) || []
            ]
          }
        })
      end
    )
    |> Map.values()
  end

  defp fomart_range_aggs(filters) do
    filters
    |> Enum.reduce(
      %{},
      fn %{"key" => id, "doc_count" => count, "facet_value" => %{"min" => min, "max" => max}},
         acc ->
        Map.merge(acc, %{
          id => %{
            "id" => id,
            "min" => min,
            "max" => max,
            "values" => [
              %{
                "id" => id,
                "count" => count,
                "meta" => ""
              }
              | (acc[id] && acc[id]["values"]) || []
            ]
          }
        })
      end
    )
    |> Map.values()
  end

  defp format_special_string_facet_agg({"special_agg_Category", aggs}) do
    %{
      "special_agg_Category" => %{
        "aggregations" => %{"buckets" => buckets}
      }
    } = aggs

    buckets
  end

  defp format_special_string_facet_agg({key, aggs}) do
    with "special_agg_" <> _ <- key do
      %{
        "aggregation" => %{
          "aggregations" => %{"buckets" => buckets}
        }
      } = aggs[key]

      buckets
    else
      _ -> []
    end
  end
end
