defmodule Snitch.Data.Schema.TaxClassTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Data.Schema.TaxClass

  describe "create_changeset/2" do
    test "fails for missing params" do
      changeset = TaxClass.create_changeset(%TaxClass{}, %{})
      assert %{name: ["can't be blank"]} == errors_on(changeset)
    end
  end

  describe "update_changeset/2" do
    test "fails if name empty" do
      tax_class = insert(:tax_class)
      params = %{name: ""}
      changeset = TaxClass.update_changeset(tax_class, params)
      assert %{name: ["can't be blank"]} == errors_on(changeset)
    end
  end
end
