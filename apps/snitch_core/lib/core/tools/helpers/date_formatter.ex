defmodule Snitch.Tools.Helper.DateFormatter do
  # defmacro __using__(_) do

  # end
  defmacro to_char(field, format) do
    quote do
      fragment("to_char(?, ?)", unquote(field), unquote(format))
    end
  end
end
