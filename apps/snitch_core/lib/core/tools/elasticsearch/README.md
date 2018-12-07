# Query Examples

```json
GET /products/_mapping

GET /products/_search
{
  "size": 0,
  "aggregations": {
    "category": {
      "nested": { "path": "taxon_path" },
      "aggregations": {
        "taxon": {
          "terms": {
            "field": "taxon_path.name"
          }
        }
      }
    },
    "options": {
      "nested": { "path": "options" },
      "aggregations": {
        "option": {
          "terms": {
            "field": "options.value"
          }
        }
      }
    }
  }
}

GET /products/_search
{
  "suggest": {
    "product-suggest": {
      "prefix": "top",
      "completion": {
        "field": "suggest_keywords",
        "size": "5",
        "skip_duplicates": "true"
      }
    }
  }
}

GET /products/_search
{
  "from": 0,
  "size": 100,
  "sort": [
    {
      "_score": {
        "order": "desc"
      }
    },
    {
      "rating_summary.average_rating": {
        "order": "desc",
        "nested": {
          "path": "rating_summary"
        }
      }
    }
  ],
  "_source": {
    "excludes": ""
  },
  "aggs": {
    "prices": {
      "histogram": {
        "field": "selling_price.amount",
        "interval": "1"
      }
    },
    "brands": {
      "nested": {
        "path": "brand"
      },
      "aggs": {
        "brand": {
          "terms": {
            "script": "doc['brand.id'].value + '|' + doc['brand.name'].value"
          }
        }
      }
    },
    "categories": {
      "nested": {
        "path": "taxon_path"
      },
      "aggs": {
        "taxon": {
          "terms": {
            "script": "doc['taxon_path.id'].value + '|' + doc['taxon_path.name'].value"
          }
        }
      }
    },
    "options": {
      "nested": {
        "path": "variants.options"
      },
      "aggregations": {
        "option": {
          "terms": {
            "script": "doc['variants.options.name'].value + '|' + doc['variants.options.value'].value"
          }
        }
      }
    }
  },
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "name": {
              "query": "cocoa lage",
              "operator": "and",
              "fuzziness": "AUTO"
            }
          }
        }
      ]
    }
  }
}

GET /products/_search
{
  "query": {
    "nested": {
      "path": "taxon_path",
      "query": {
        "bool": {
          "filter": [
            {
              "match": {
                "taxon_path.id": 2
              }
            }
          ]
        }
      }
    }
  }
}

GET /products/_doc/_search
{
  "size": 20,
  "_source": {
    "excludes": [""]
  },
  "query": {
    "match_all": {}
  }
}

DELETE /products

```
