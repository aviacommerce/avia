defmodule Snitch.Data.Schema.TaxConfig do
  @moduledoc """
  Models the general configuration for Tax.

  ## Note
  At present single row modelling is being used to handle
  storing general configuration for tax. A detailed reason
  for picking up the type of modelling can be seen
  [here](https://www.pivotaltracker.com/story/show/163364131).
  """

  use Snitch.Data.Schema
  alias Snitch.Data.Schema.{TaxClass, Country, State}

  @typedoc """
  Represents the tax configuration

  -`label`: A label for the tax, the same would be used while showing on the
    frontend e.g. SalesTax.
  - `included_in_price?`: A boolean to check if tax is already set in the product
    selling price.
  - `calculation_address_type`: The address which would be used for tax calculation,
    it can be set to `shipping` or `billing` or store address.
  - `shipping_tax_class`: The tax class that would be used while calculating shipping
    tax.
  - `gift_tax`: The tax class to be used while calculating gift tax.
  - `default_country`: This field is used to set the default tax country. It is used
    to calculate taxes if prices are inclusive of tax.
  - `default_state`: The field is used to set the default tax state. If set a zone containing
    the state would be used for calculating tax if they are included in prices.
  - `preferences`: A json field to store all the other params in a jsonb map.
  """
  @type t :: %__MODULE__{}

  schema "snitch_tax_configuration" do
    field(:label, :string)
    field(:included_in_price?, :boolean, default: true)
    field(:calculation_address_type, AddressTypes, default: :shipping_address)
    field(:preferences, :map)

    belongs_to(:shipping_tax, TaxClass)
    belongs_to(:gift_tax, TaxClass)
    belongs_to(:default_country, Country)
    belongs_to(:default_state, State)

    timestamps()
  end

  @required ~w(label shipping_tax_id default_country_id)a
  @optional ~w(default_state_id gift_tax_id included_in_price? calculation_address_type)a
  @permitted @required ++ @optional

  def create_changeset(%__MODULE__{} = config, params) do
    config
    |> cast(params, @permitted)
    |> common_changeset()
  end

  def update_changeset(%__MODULE__{} = config, params) do
    config
    |> cast(params, @permitted)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> validate_required(@required)
    |> foreign_key_constraint(:shipping_tax_id)
    |> foreign_key_constraint(:gift_tax_id)
    |> foreign_key_constraint(:default_country_id)
    |> foreign_key_constraint(:default_state_id)
  end
end
