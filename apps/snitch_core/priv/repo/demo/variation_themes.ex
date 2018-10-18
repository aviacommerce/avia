defmodule Snitch.Demo.VariationTheme do

    alias Snitch.Core.Tools.MultiTenancy.Repo
    alias Snitch.Data.Schema.VariationTheme
    alias Snitch.Data.Schema.OptionType

    defp get_option_type do
        Repo.all(OptionType)
    end

    def create_variation_themes do
        Repo.delete_all(VariationTheme)
        option_types = get_option_type
        option_ids = for option <- option_types, do: to_string(option.id)
        create_variation_theme!("color", [Enum.at(option_ids, 0)])
        create_variation_theme!("size", [Enum.at(option_ids, 1)])
        create_variation_theme!("color-size", option_ids)
    end

    def create_variation_theme!(name, option_type_ids) do
        params = %{
          "name" => name,
          "option_type_ids" => option_type_ids
        }
        %VariationTheme{} |> VariationTheme.create_changeset(params) |> Repo.insert!
    end

end
