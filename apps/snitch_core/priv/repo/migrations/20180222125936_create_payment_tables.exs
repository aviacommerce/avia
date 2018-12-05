defmodule Core.Repo.Migrations.CreatePaymentTables do
  use Ecto.Migration

  @payment_exclusivity_fn ~s"""
  create or replace function #{ prefix() || "public" }.payment_exclusivity(
    in supertype_id bigint,
    in subtype_discriminator char(3)
    )
  returns integer
  as $$
    select coalesce(
      (select 1
      from  #{ prefix() || "public" }.snitch_payments
        where id = supertype_id
        and   payment_type = subtype_discriminator),
      0)
  $$
  language sql;
  """

  def change do
    create table("snitch_payment_methods") do
      add :name, :string, null: :false
      add :code, :char, size: 3
      add :active?, :boolean, default: true, null: :false
      timestamps()
    end
    create unique_index("snitch_payment_methods", :code)

    create table("snitch_payments", comment: "payment supertype") do
      add :payment_method_id, references("snitch_payment_methods"), null: false
      add :payment_type, :char, size: 3, comment: "discriminator", null: false
      add :slug, :string, null: false
      add :amount, String.to_atom("money_with_currency")
      add :state, :string, default: "pending"
      add :order_id, references("snitch_orders"), null: false
      timestamps()
    end
    create unique_index("snitch_payments", :slug)

    create table("snitch_card_payments", comment: "payments made via credit or debit cards") do
      add :payment_id, references("snitch_payments", on_delete: :delete_all), null: false
      add :response_code, :string
      add :response_message, :text
      add :avs_response, :string
      add :cvv_response, :string
      timestamps()
    end
    create unique_index("snitch_card_payments", :payment_id)

    execute @payment_exclusivity_fn, "drop #{ prefix() || "public" }.function payment_exclusivity;"
  end
end
