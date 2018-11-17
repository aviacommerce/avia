defmodule Snitch.Seed.VariationTheme do

  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias Snitch.Data.Schema.VariationTheme
  alias Snitch.Data.Schema.OptionType

  defp get_option_type do
    Repo.all(OptionType)
  end

  def seed!() do
    option_types = get_option_type
    option_ids = for option <- option_types, do: to_string(option.id)
    option_names = for option <- option_types, do: option.name
    for option <- option_types, do: create_variation_theme(option.name, [to_string(option.id)])
    create_variation_theme(Enum.join(option_names, "-"), option_ids)
  end

  def create_variation_theme(name, option_type_ids) do
    params = %{
      "name" => name,
      "option_type_ids" => option_type_ids
    }
    %VariationTheme{} |> VariationTheme.create_changeset(params) |> Repo.insert!
end

end
