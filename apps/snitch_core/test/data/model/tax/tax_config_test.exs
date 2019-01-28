defmodule Snitch.Data.Model.TaxConfigtest do
  @moduledoc false

  use ExUnit.Case, async: true
  use Snitch.DataCase
  import Snitch.Factory
  alias Snitch.Data.Model.TaxConfig

  describe "update/2" do
    test "success" do
      state = insert(:state)
      country = state.country
      tax_config = insert(:tax_config, default_state: state, default_country: country)

      state_new = insert(:state, country: country)

      params = %{label: "Taxes", default_state_id: state_new.id}
      assert {:ok, _data} = TaxConfig.update(tax_config, params)
    end
  end

  describe "get/1" do
    test "success" do
      tax_config = insert(:tax_config)

      assert {:ok, config} = TaxConfig.get(tax_config.id)
      assert config.id == tax_config.id
      assert config.label == tax_config.label
    end

    test "fails" do
      insert(:tax_config)

      assert {:error, message} = TaxConfig.get(-1)
      assert message == :tax_config_not_found
    end
  end

  describe "get_default/0" do
    test "gets successfully" do
      tax_config = insert(:tax_config)
      data = TaxConfig.get_default()
      assert data.id == tax_config.id
    end

    test "raises if more than one record are present" do
      insert(:tax_config)
      insert(:tax_config)

      assert_raise Ecto.MultipleResultsError, fn ->
        TaxConfig.get_default()
      end
    end
  end

  test "get all tax_address_types" do
    addresses = TaxConfig.tax_address_types()

    assert [
             shipping_address: "shipping_address",
             billing_address: "billing_address",
             store_address: "store_address"
           ] = addresses
  end
end
