defmodule Snitch.Tools.ElasticsearchCluster do
  @moduledoc false
  use Elasticsearch.Cluster, otp_app: :snitch_core
end
