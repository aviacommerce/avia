[
  inputs: [
    "apps/*/{lib,config}/*.{ex,exs}", # lib and config
    "apps/*/test/*.{ex,exs}", # tests
    # "apps/*/priv/repo/migrations/*.{ex,exs}", # migrations
    "apps/*/mix.exs", # mix files
    "mix.exs", # top-level
  ],
  locals_with_parens: [add: :*]
]
