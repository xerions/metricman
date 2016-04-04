# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :setup, :verify_directories, false

config :exometer_core, :predefined, [
  {[:erlang, :system_info], {:function, :erlang, :system_info, [:'$dp'], :value, [:port_count, :process_count, :thread_pool_size]}, []},
  {[:erlang, :statistics], {:function, :erlang, :statistics, [:'$dp'], :value, [:run_queue]}, []},
  {[:erlang, :statistics, :garbage_collection], {:function, Metricman, :garbage_collection, [], :value, [:number_of_gcs, :words_reclaimed]}, []},
  {[:erlang, :statistics, :io], {:function, Metricman, :io, [], :value, [:input, :output]}, []},
  {[:erlang, :memory], {:function, :erlang, :memory, [:'$dp'], :value, [:total, :processes, :processes_used, :system, :ets, :binary, :code, :atom, :atom_used]}, []},
  {[:erlang, :scheduler, :usage], {:function, :recon, :scheduler_usage, [1000], :proplist, :lists.seq(1, :erlang.system_info(:schedulers))}, []},
  {[:erlang, :beam, :start_time], :gauge, []},
  {[:erlang, :beam, :uptime], {:function, Metricman, :update_uptime, [], :proplist, [:value]}, []}
]

if Mix.env == :test do
  config :exometer_core, :report,
    reporters:  [{Metricman.DummyReporter, []}]
end
