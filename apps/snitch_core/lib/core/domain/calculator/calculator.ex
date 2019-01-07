defmodule Snitch.Domain.Calculator do
  @moduledoc """
  Base Calculator module.
  """

  @defaults Application.get_env(:snitch_core, :defaults_module)
  @user_config Application.get_env(:snitch_core, :user_config_module)

  @doc """
  Returns a Money struct after performing computation.

  Takes as input `item` and `value`.
  > Note
  > `value` refers to rate/rates to be used for computation.
  > `item` is something on which the computation is done.
  """
  @callback compute(value :: map, item :: map | nil) :: Money.t()

  @doc """
  Returns a list of calculators.

  The list includes the calculators defined in the `core` app as well as,
  those defined by the `user` under `snitch_core` config.
  """
  @spec list :: [atom]
  def list do
    case @defaults.fetch(:calculators) do
      {:ok, value} -> value ++ @user_config.get(:calculators)
      {:error, _} = value -> value
    end
  end
end
