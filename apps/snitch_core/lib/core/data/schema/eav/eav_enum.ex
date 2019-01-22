import EctoEnum

## Note
# Refrain from modfiying the order it will lead to unforseeable
# incosistencies.

defenum(AttributeDataType,
  "Elixir.Snitch.Data.Schema.EAV.Boolean": 0,
  "Elixir.Snitch.Data.Schema.EAV.Integer": 1,
  "Elixir.Snitch.Data.Schema.EAV.String": 2,
  "Elixir.Snitch.Data.Schema.EAV.Decimal": 3,
  "Elixir.Snitch.Data.Schema.EAV.DateTime": 4
)

defenum(AttributeRelations,
  "Elixir.Snitch.Data.Schema.Country": 0,
  "Elixir.Snitch.Data.Schema.State": 1
)

defenum(EntityIdentifier,
  tax: 0
)
