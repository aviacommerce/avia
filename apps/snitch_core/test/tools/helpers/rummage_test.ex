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

  @conn_query_with_referer %{
    "rummage[search][state][search_expr]" => "where",
    "rummage[search][state][search_term]" => "in_active",
    "rummage[search][state][search_type]" => "eq",
    "rummage[sort][field]" => "name",
    "rummage[sort][order]" => "asc"
  }

  @conn_query_with_no_referer %{}

  describe "when conn has referer." do
    test "get_rummage_params/1" do
      assert @conn_query_with_referer = Rummage.get_rummage_params(@conn_with_referer)
    end
  end

  describe "when conn has no referer." do
    test "get_rummage_params/1" do
      assert @conn_query_with_no_referer = Rummage.get_rummage_params(@conn_with_no_referer)
    end
  end
end
