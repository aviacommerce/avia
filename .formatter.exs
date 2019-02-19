[
  inputs: [
    # lib and config
    "apps/*/{lib,config}/**/*.{ex,exs}",
    # tests
    "apps/*/test/**/*.{ex,exs}",
    # "apps/*/priv/repo/migrations/*.{ex,exs}", # migrations
    # seeds
    "apps/*/priv/repo/seed/*.{ex,exs}",
    # demo
    "apps/*/priv/repo/demo/*.{ex,exs}",
    # mix files
    "apps/*/mix.exs",
    # top-level
    "mix.exs"
  ]
]
