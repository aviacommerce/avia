defmodule Snitch.Repo.Migrations.UpdateProductStateType do
  use Ecto.Migration

  def up do
    StatusEnum.create_type
    alter table("snitch_products") do
      modify :state, StatusEnum.type(), null:false, default: 0
    end

    state_map = StatusEnum.__enum_map__() |> Enum.into(%{}, fn(x) -> {elem(x, 0) |> Atom.to_string, elem(x, 1)} end)
    from(p in "snitch_products",
    update: [set: [state: ^state_map |> Map.get(p.state)]],
    where: p.state in StatusEnum.__valid_values__())
    |> Snitch.Repo.update_all([])
  end

  def down do
    alter table("snitch_products") do
      modify :state, :string, null: false, default: "draft"
    end

    state_map = StatusEnum.__enum_map__() |> Enum.into(%{}, fn(x) -> {elem(x, 1), elem(x, 0) |> Atom.to_string} end)
    from(p in "snitch_products",
    update: [set: [state: ^state_map |> Map.get(p.state)]],
    where: p.state in StatusEnum.__valid_values__())
    |> Snitch.Repo.update_all([])
  end
end
