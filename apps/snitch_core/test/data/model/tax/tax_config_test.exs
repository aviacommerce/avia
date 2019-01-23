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
end
