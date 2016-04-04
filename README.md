# Metricman [![Build Status](https://travis-ci.org/xerions/metricman.svg?branch=master)](https://travis-ci.org/xerions/metricman)

It is just meta package which depends on [Feuerlabs/exometer_core](https://github.com/xerions/exometer), [travelping/exometer_influxdb](https://github.com/travelping/exometer_influxdb) and configures some VM metrics like this:

    system_info  port_count
    system_info  process_count
    system_info  thread_pool_size
    statistics   run_queue
    statistics   garbage_collection
    statistics   io
    memory       total
    memory       processes
    memory       ets
    memory       binary
    memory       atom
    memory       atom_used
    memory       maximum

You can see the created metrics in `config/config.exs`. Note that the metrics are only created. If you want to expose them via a reporter then you need to subscribe to them within your application.

## Dependencies tree

    xerions/metricman 
    `--> travelping/exometer_influxdb
         `--> Feuerlabs/exometer_core
             `--> basho/lager
             |    `--> DeadZen/goldrush
             `--> uwiger/parse_trans
             |    `--> uwiger/edown
             `--> eproxus/meck
             `--> boundary/folsom
             |    `--> boundary/bear
             `--> uwiger/setup
             |    `--> uwiger/edown
         `--> benoitc/hackney
             `--> benoitc/erlang-idna
             `--> benoitc/mimerl
             `--> benoitc/metrics
             `--> certifi/erlang-certifi
             `--> deadtrickster/ssl_verify_hostname

## Usage

1. Add metricman to your list of dependencies in mix.exs:

    ```elixir
    def deps do
        [{:metricman, github: "xerions/metricman"}]
    end
    ```

2. Ensure metricman is started before your application:

    ```elixir
    def application do
        [applications: [:metricman]]
    end
    ```

3. Include the metricman configuration to your config.exs:

    ```elixir
    try do 
        import_config "../deps/metricman/config/config.exs"
    rescue
        _  in _ -> :skip
    end
   ```

4. And you can add your own exometer reporter in your config.exs:

    ```elixir
    config :exometer_core, :report,
        reporters: [
            {:exometer_report_influxdb, [{:protocol, :http},
                                         {:host, "localhost"},
                                         {:port, 8086},
                                         {:db, "exometer"},
                                         {:tags, [{:region, :ru}]}]}
        ]
    ```

    or for InfluxDB you can use conform config:

    ```
    influx.db = http://127.0.0.1:8086/default_db
    influx.tags = node:node_name,region:de
    influx.batch_window_size = 50
    ```

    See [this](https://github.com/Feuerlabs/exometer/blob/master/doc/README.md#configuring-reporter-plugins) for more information about configuring the reportes plugins.
