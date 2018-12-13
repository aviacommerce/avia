defmodule Snitch.Demo.StockLocation do
  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias NimbleCSV.RFC4180, as: CSV
  alias Snitch.Data.Schema.{StockLocation, State}

  @base_path Application.app_dir(:snitch_core, "priv/repo/demo/demo_data")

  def create_stock_locations do
    Repo.delete_all(StockLocation)
    state = get_random_state
    product_path = Path.join(@base_path, "stock_locations.csv")

    product_path
    |> File.read!()
    |> CSV.parse_string()
    |> Enum.each(fn [
                      name,
                      default,
                      address_line_1,
                      address_line_2,
                      city,
                      zip_code,
                      phone,
                      propagate_all_variants,
                      active
                    ] ->
      default = String.to_existing_atom(default)
      active = String.to_existing_atom(active)
      propagate_all_variants = String.to_existing_atom(propagate_all_variants)

      create_stock_location!(
        name,
        default,
        address_line_1,
        address_line_2,
        city,
        zip_code,
        phone,
        propagate_all_variants,
        active,
        state,
        state.country
      )
    end)
  end

  defp get_random_state do
    State
    |> Repo.all()
    |> Repo.preload([:country])
    |> Enum.random()
  end

  def create_stock_location!(
        name,
        default,
        address_line_1,
        address_line_2,
        city,
        zip_code,
        phone,
        propagate_all_variants,
        active,
        state,
        country
      ) do
    params = %{
      name: name,
      default: default,
      address_line_1: address_line_1,
      address_line_2: address_line_2,
      city: city,
      zip_code: zip_code,
      phone: phone,
      propagate_all_variants: propagate_all_variants,
      active: active,
      state_id: state.id,
      country_id: country.id
    }

    %StockLocation{} |> StockLocation.create_changeset(params) |> Repo.insert!()
  end
end
