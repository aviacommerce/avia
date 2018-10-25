defmodule Snitch.Tools.Helper.QueryFragment do
  defmacro to_char(field, format) do
    quote do
      fragment("to_char(?, ?)", unquote(field), unquote(format))
    end
  end
end
