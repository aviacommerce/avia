defmodule Snitch.Tools.GenNanoid do
  # to be mocked
  def gen_nano_id() do
    Nanoid.generate(10, "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ")
  end
end
