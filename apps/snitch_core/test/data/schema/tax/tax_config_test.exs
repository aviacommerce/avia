defmodule Snitch.Data.Schema.TaxConfigTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Data.Schema.TaxConfig

  describe "create_changeset/2" do
    test "fails for missing params" do
      params = %{}
      changeset = TaxConfig.create_changeset(%TaxConfig{}, params)

      assert %{
               default_country_id: ["can't be blank"],
               label: ["can't be blank"],
               shipping_tax_id: ["can't be blank"]
             } == errors_on(changeset)
    end

    test "failure for foreign key constraints" do
      tax_class = insert(:tax_class)

      params = %{
        default_state_id: -1,
        default_country_id: -1,
        shipping_tax_id: -1,
        gift_tax_id: -1,
        label: "SalesTax"
      }

      changeset = TaxConfig.create_changeset(%TaxConfig{}, params)
      assert {:error, cset} = Repo.insert(changeset)
      assert %{shipping_tax_id: ["does not exist"]} == errors_on(cset)

      params = %{params | shipping_tax_id: tax_class.id, gift_tax_id: tax_class.id}

      changeset = TaxConfig.create_changeset(%TaxConfig{}, params)
      assert {:error, cset} = Repo.insert(changeset)
      assert %{default_country_id: ["does not exist"]} = errors_on(cset)
    end
  end
end
