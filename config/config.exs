# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :setup, :verify_directories, false

config :exometer, :predefined, [
  {[:erlang, :system_info], {:function, :erlang, :system_info, [:'$dp'], :value, [:port_count, :process_count, :thread_pool_size]}, []},
  {[:erlang, :statistics], {:function, :erlang, :statistics, [:'$dp'], :value, [:run_queue]}, []},
  {[:erlang, :statistics, :garbage_collection], {:function, Metricman, :garbage_collection, [], :value, [:number_of_gcs, :words_reclaimed]}, []},
  {[:erlang, :statistics, :io], {:function, Metricman, :io, [], :value, [:input, :output]}, []},
  {[:erlang, :memory], {:function, :erlang, :memory, [:'$dp'], :value, [:total, :processes, :processes_used, :system, :ets, :binary, :code, :atom, :atom_used]}, []}
]

config :metricman, :subscriptions, [
    {[:erlang, :system_info], :port_count, 2000},
    {[:erlang, :system_info], :process_count, 2000},
    {[:erlang, :system_info], :thread_pool_size, 2000},
    {[:erlang, :statistics], :run_queue, 2000},
    {[:erlang, :statistics, :garbage_collection], :number_of_gcs, 2000},
    {[:erlang, :statistics, :garbage_collection], :words_reclaimed, 2000},
    {[:erlang, :statistics, :io], :input, 2000},
    {[:erlang, :statistics, :io], :output, 2000},
    {[:erlang, :memory], :total, 2000},
    {[:erlang, :memory], :processes, 2000},
    {[:erlang, :memory], :processes_used, 2000},
    {[:erlang, :memory], :system, 2000},
    {[:erlang, :memory], :ets, 2000},
    {[:erlang, :memory], :binary, 2000},
    {[:erlang, :memory], :code, 2000},
    {[:erlang, :memory], :atom, 2000},
    {[:erlang, :memory], :atom_used, 2000}
  ]

if Mix.env == :test do
  config :exometer, :report,
    reporters:  [{:exometer_report_tty, []}]
end
