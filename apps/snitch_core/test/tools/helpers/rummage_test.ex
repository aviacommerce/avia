defmodule Snitch.Tools.RummageTest do
  use ExUnit.Case, async: false

  alias Snitch.Tools.Helper.Rummage

  @conn_with_referer %{
    req_headers: [
      {"referer",
       "http://0.0.0.0:4000/products?rummage[sort][field]=name&rummage[sort][order]=asc&rummage[search][state][search_expr]=where&rummage[search][state][search_type]=eq&rummage[search][state][search_term]=in_active"}
    ]
  }

  @conn_with_no_referer %{
    req_headers: []
  }

  @conn_query_with_referer "rummage[sort][field]=name&rummage[sort][order]=asc&rummage[search][state][search_expr]=where&rummage[search][state][search_type]=eq&rummage[search][state][search_term]=in_active"

  @conn_query_with_no_referer ""

  describe "when conn has referer." do
    test "query_string_from_request_referer/1" do
      assert @conn_query_with_referer =
               Rummage.query_string_from_request_referer(@conn_with_referer)
    end
  end

  describe "when conn has no referer." do
    test "query_string_from_request_referer/1" do
      assert @conn_query_with_no_referer =
               Rummage.query_string_from_request_referer(@conn_with_no_referer)
    end
  end
end
