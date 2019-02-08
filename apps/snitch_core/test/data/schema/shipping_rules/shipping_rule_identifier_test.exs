defmodule Snitch.Data.Schema.ShippingRuleIdentifierTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase

  import Snitch.Factory

  alias Snitch.Data.Schema.ShippingRuleIdentifier, as: SRIdentifier

  setup do
    si = insert(:shipping_identifier)
    params = Map.from_struct(si)

    [params: params]
  end

  describe "changeset/2" do
    test "returns valid changeset", %{params: params} do
      cs = SRIdentifier.changeset(%SRIdentifier{}, params)
      assert cs.valid?
    end

    test "fails for invalid params", %{params: params} do
      params = %{params | code: nil, description: ""}
      changeset = SRIdentifier.changeset(%SRIdentifier{}, params)
      assert %{code: ["can't be blank"], description: ["can't be blank"]} == errors_on(changeset)
    end

    test "fails for duplicate code value", %{params: params} do
      changeset = SRIdentifier.changeset(%SRIdentifier{}, params)
      {:error, changeset} = Repo.insert(changeset)
      assert %{code: ["has already been taken"]} == errors_on(changeset)
    end

    test "returns a valid changeset for valid code value", %{params: params} do
      params = %{params | code: :fsoa, description: "free shipping above specified amount"}
      changeset = SRIdentifier.changeset(%SRIdentifier{}, params)
      assert changeset.valid?

      params = %{params | code: :fsrp, description: "fixed shipping rate per product"}
      changeset = SRIdentifier.changeset(%SRIdentifier{}, params)
      assert changeset.valid?

      params = %{params | code: :ofr, description: "fixed shipping rate for order"}
      changeset = SRIdentifier.changeset(%SRIdentifier{}, params)
      assert changeset.valid?

      params = %{params | code: :fso, description: "free shipping for order"}
      changeset = SRIdentifier.changeset(%SRIdentifier{}, params)
      assert changeset.valid?
    end

    test "fails for invalid code value", %{params: params} do
      params = %{params | code: :ofrr}
      changeset = SRIdentifier.changeset(%SRIdentifier{}, params)
      assert %{code: ["is invalid"]} == errors_on(changeset)
    end

    test "identifier_with_module returns the defined map" do
      expected_map = %{
        fso: %{
          description: "free shipping for order",
          module: Snitch.Data.Schema.ShippingRule.OrderFree
        },
        fsoa: %{
          description: "free shipping above specified amount",
          module: Snitch.Data.Schema.ShippingRule.OrderConditionalFree
        },
        fsrp: %{
          description: "fixed shipping rate per product",
          module: Snitch.Data.Schema.ShippingRule.ProductFlatRate
        },
        ofr: %{
          description: "fixed shipping rate for order",
          module: Snitch.Data.Schema.ShippingRule.OrderFlatRate
        }
      }

      assert expected_map = SRIdentifier.identifier_with_module()
    end
  end
end
