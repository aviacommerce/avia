defmodule Snitch.Tools.Helper.Rummage do
  def get_rummage_params(conn) do
    conn.req_headers
    |> Enum.into(%{})
    |> get_referer()
    |> parse_uri()
    |> decode_query()
  end

  defp get_referer(%{"referer" => referer}), do: referer

  defp get_referer(_), do: nil

  defp parse_uri(nil), do: nil

  defp parse_uri(uri), do: URI.parse(uri)

  defp decode_query(nil), do: Map.new()

  defp decode_query(%{query: nil}), do: Map.new()

  defp decode_query(%{query: query}), do: URI.decode_query(query)
end
