defmodule Snitch.Seed.OptionType do
  alias Snitch.Core.Tools.MultiTenancy.Repo
  alias Snitch.Data.Schema.OptionType

  @base_path Application.app_dir(:snitch_core, "priv/repo/demo/demo_data")

  def seed!() do
    create_option_type("size", "Size")
    create_option_type("color", "Color")
  end

  def create_option_type(name, display_name) do
    params = %{
      name: name,
      display_name: display_name
    }

    %OptionType{} |> OptionType.create_changeset(params) |> Repo.insert!()
  end
end
