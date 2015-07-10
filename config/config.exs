# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :exometer, :predefined, [
  {[:erlang, :system_info], {:function, :erlang, :system_info, [:'$dp'], :value, [:port_count, :process_count, :thread_pool_size]}, []},
  {[:erlang, :statistics], {:function, :erlang, :statistics, [:'$dp'], :value, [:run_queue]}, []},
  {[:erlang, :memory], {:function, :erlang, :memory, [:'$dp'], :value, [:total, :processes, :ets, :binary, :atom, :atom_used, :maximum]}, []}
]

config :exometer, :report,
  reporters: [
    {:exometer_report_graphite, [{:host, 'localhost'}, {:port, 2003}, {:api_key, 'exometer'}]}
  ],
  subscribers: [
    {:exometer_report_graphite, [:erlang, :system_info], :port_count, 1000, true},
    {:exometer_report_graphite, [:erlang, :system_info], :process_count, 1000, true},
    {:exometer_report_graphite, [:erlang, :system_info], :thread_pool_size, 1000, true},
    {:exometer_report_graphite, [:erlang, :statistics], :run_queue, 1000, true},
    {:exometer_report_graphite, [:erlang, :memory], :total, 2000, true},
    {:exometer_report_graphite, [:erlang, :memory], :processes, 2000, true},
    {:exometer_report_graphite, [:erlang, :memory], :ets, 2000, true},
    {:exometer_report_graphite, [:erlang, :memory], :binary, 2000, true},
    {:exometer_report_graphite, [:erlang, :memory], :atom, 2000, true},
    {:exometer_report_graphite, [:erlang, :memory], :atom_used, 2000, true},
    {:exometer_report_graphite, [:erlang, :memory], :maximum, 2000, true}
  ]
