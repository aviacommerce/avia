[
  inputs: [
    "apps/*/{lib,config}/**/*.{ex,exs}", # lib and config
    "apps/*/test/**/*.{ex,exs}", # tests
    # "apps/*/priv/repo/migrations/*.{ex,exs}", # migrations
    "apps/*/priv/repo/*.{ex,exs}", # seeds
    "apps/*/mix.exs", # mix files
    "mix.exs", # top-level
  ]
]
