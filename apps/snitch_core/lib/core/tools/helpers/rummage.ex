defmodule Snitch.Tools.Helper.Rummage do
  def query_string_from_request_referer(conn) do
    conn.req_headers
    |> Enum.into(%{})
    |> Map.get("referer", "")
    |> URI.parse()
    |> Map.get(:query) || ""
  end
end
