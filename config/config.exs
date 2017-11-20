# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :setup, :verify_directories, false

config :exometer_core, :predefined, [
  {[:erlang, :otp_release], {:function, :erlang, :system_info, [:'$dp'], :value, [:otp_release]}, []},
  {[:erlang, :beam, :port],    {:function, :erlang, :system_info, [:'$dp'], :value, [:port_count, :port_limit]}, []},
  {[:erlang, :beam, :process], {:function, Metricman, :process_info, [], :proplist, [:process_count, :process_limit, :run_queue_size]}, []},
  {[:erlang, :beam, :processor], {:function, :erlang, :system_info, [:'$dp'], :value, [:logical_processors, :logical_processors_available, :logical_processors_online]}, []},
  {[:erlang, :beam, :garbage_collection], {:function, Metricman, :garbage_collection, [], :value, [:number_of_gcs, :words_reclaimed]}, []},
  {[:erlang, :beam, :io], {:function, Metricman, :io, [], :value, [:input, :output]}, []},
  {[:erlang, :beam, :memory], {:function, :erlang, :memory, [:'$dp'], :value, [:total, :processes, :processes_used, :system, :ets, :binary, :code, :atom, :atom_used]}, []},
  #{[:erlang, :beam, :scheduler_usage], {:function, :recon, :scheduler_usage, [1000], :proplist, :lists.seq(1, :erlang.system_info(:schedulers))}, []},
  {[:erlang, :beam, :start_time], :gauge, []},
  {[:erlang, :beam, :uptime], {:function, Metricman, :update_uptime, [], :proplist, [:value]}, []}
]

if Mix.env == :test do
  config :exometer_core, :report,
    reporters:  [{Metricman.DummyReporter, []}]
end
