defmodule Snitch.StartupCode do
  @moduledoc """
  Code that runs just after the app starts
  """
  alias Snitch.Repo
  alias Snitch.Data.Schema.GeneralConfiguration, as: GC

  def run do
    case Repo.all(GC) |> List.first() do
      nil ->
        nil

      general_configuration ->
        Application.put_env(
          :snitch_core,
          Snitch.Tools.Mailer,
          sendgrid_sender_mail: general_configuration.sender_mail,
          api_key: general_configuration.sendgrid_api_key,
          adapter: Bamboo.SendGridAdapter
        )
    end
  end
end
