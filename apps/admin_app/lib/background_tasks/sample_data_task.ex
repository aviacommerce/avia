defmodule AdminApp.Task do
  def work do
    Triplex.drop("default_db")
    Triplex.create("default_db")
    seed_path = Application.app_dir(:snitch_core, "/priv/repo/seed/seeds.exs")
    demo_path = Application.app_dir(:snitch_core, "/priv/repo/demo/demo.exs")
    Code.eval_file(seed_path)
    Code.eval_file(demo_path)
    IO.puts("Data Created Successfully")
  end
end
