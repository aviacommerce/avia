defmodule Snitch.Factory.Returns do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      alias Snitch.Data.Schema.{ReturnAuthorizationReason, ReturnAuthorization}

      def return_authorization_reason_factory do
        %ReturnAuthorizationReason{
          name: sequence("Boom"),
          active: true
        }
      end

      def return_authorization_factory do
        %ReturnAuthorization{
          number: sequence("R123456"),
          state: "Default",
          memo: "Test",
          order: insert(:order, user_id: insert(:user).id),
          return_authorization_reason: build(:return_authorization_reason)
        }
      end
    end
  end
end
