defmodule Snitch.Seed.Returns do
  @moduledoc false

  import Ecto.Query

  alias Snitch.Repo
  alias Snitch.Data.Schema.ReturnAuthorizationReason, as: RARSchema
  alias Snitch.Data.Model.ReturnAuthorizationReason, as: RARModel
  alias Snitch.Data.Schema.ReturnAuthorization, as: RASchema
  alias Snitch.Data.Model.ReturnAuthorization, as: RAModel
  alias Snitch.Data.Model.Order, as: OrderModel  

  require Logger

  def seed! do
    seed_return_authorization_reasons()
    seed_return_authorizations()
  end

  defp seed_return_authorization_reasons do
    reasons = [
      %{name: "Faulty Product"},
      %{name: "Broken Pacakage"},
      %{name: "Ordered by mistake"}
    ]
    |> Enum.map(
      &Map.merge(&1,
        %{
          inserted_at: Ecto.DateTime.utc(),
          updated_at: Ecto.DateTime.utc()
        }
      )
    )

    {count, _} = Repo.insert_all(RARSchema, reasons, on_conflict: :nothing)
    Logger.info("Inserted #{count} Return Authorizaion reasons")
  end

  defp seed_return_authorizations do
    orders = OrderModel.get_all()
    reasons = RARModel.get_all()
    return_auths = [
      %{
        number: "R123456789", 
        state: "pending", 
        memo: "Package was open",
        order_id: List.first(orders).id, 
        return_authorization_reason_id:  List.first(reasons).id
      },
      %{
        number: "R987654321", 
        state: "pending", 
        memo: "Package not recieved",
        order_id: List.first(orders).id, 
        return_authorization_reason_id:  List.last(reasons).id
      }
    ]
    |> Enum.map(
      &Map.merge(&1,
        %{
          inserted_at: Ecto.DateTime.utc(),
          updated_at: Ecto.DateTime.utc()
        }
      )
    )

    {count, _} = Repo.insert_all(RASchema, return_auths, on_conflict: :nothing)
    Logger.info("Inserted #{count} Return Authorizaion")
  end
end
