defmodule Snitch.Domain.OrderTest do
  use ExUnit.Case, async: true
  use Snitch.DataCase
  use Ecto.Schema

  import Ecto.Changeset, only: [change: 2]
  import Snitch.Factory

  alias Snitch.Domain.Order, as: OrderDomain

  describe "validate_changes/1" do
    test "with order in frozen state" do
      {:error, cs} =
        :line_item
        |> insert(order: build(:order, state: :cancelled))
        |> change(%{quantity: 3})
        |> OrderDomain.validate_change()
        |> Repo.update()

      assert %{order: ["has been frozen"]} == errors_on(cs)
    end

    test "with order in editable state" do
      assert {:ok, _} =
               :line_item
               |> insert(order: build(:order))
               |> change(%{quantity: 3})
               |> OrderDomain.validate_change()
               |> Repo.update()
    end

    test "noop when `:changes` is empty" do
      assert {:ok, _} =
               :line_item
               |> insert(order: build(:order))
               |> change(%{})
               |> OrderDomain.validate_change()
               |> Repo.update()
    end
  end
end
