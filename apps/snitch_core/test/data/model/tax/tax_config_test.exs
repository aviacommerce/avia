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
end
