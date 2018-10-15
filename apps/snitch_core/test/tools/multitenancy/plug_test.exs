defmodule Snitch.Tools.MultiTenancy.PlugTest do
  use ExUnit.Case, async: false
  use Snitch.DataCase

  defmodule TestEndpoint do
    def config(:url) do
      [host: "avia.com"]
    end
  end

  alias Snitch.Core.Tools.MultiTenancy

  test "plug handles root domain" do
    conn =
      %Plug.Conn{
        host: "avia.com"
      }
      |> MultiTenancy.Plug.call(endpoint: TestEndpoint)

    assert is_nil(conn.status())
  end

  test "plug handles reserved domain" do
    conn =
      %Plug.Conn{
        host: "api.avia.com"
      }
      |> MultiTenancy.Plug.call(endpoint: TestEndpoint)

    assert is_nil(conn.status())
  end

  test "plug handles non existent domain" do
    conn =
      %Plug.Conn{
        host: "no_tenant.avia.com"
      }
      |> MultiTenancy.Plug.call(endpoint: TestEndpoint)

    assert conn.status() == 404
  end
end
