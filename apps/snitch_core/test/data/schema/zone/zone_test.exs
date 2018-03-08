defmodule Snitch.Data.Schema.ZoneTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  alias Snitch.Data.Schema.Zone

  test "Zone invalidates bad type" do
    params = %{name: "foobar", description: "non-existent"}
    zone = Zone.changeset(%Zone{zone_type: "x"}, params, :create)

    assert %Ecto.Changeset{errors: errors} = zone
    assert errors == [zone_type: {"'x' is invalid", [validation: :inclusion]}]
  end
end
