#!/bin/bash
mix ecto.create
mix ecto.migrate
mix run apps/snitch_core/priv/repo/seed/seeds.exs
mix cmd --app snitch_core mix elasticsearch.build products --cluster Snitch.Tools.ElasticsearchCluster
mix phx.server