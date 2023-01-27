[
  import_deps: [:ecto, :phoenix],
  inputs: [
    "apps/*/{lib,config}/**/*.{heex, ex,exs}", # lib and config
    "apps/*/test/**/*.{ex,exs}", # tests
    # "apps/*/priv/repo/migrations/*.{ex,exs}", # migrations
    "apps/*/priv/repo/seed/*.{ex,exs}", # seeds
    "apps/*/priv/repo/demo/*.{ex,exs}", #demo
    "apps/*/mix.exs", # mix files
    "mix.exs", # top-level
  ],
  plugins: [Phoenix.LiveView.HTMLFormatter],
]
