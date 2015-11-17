# Metricman [![Build Status](https://travis-ci.org/xerions/metricman.svg?branch=master)](https://travis-ci.org/xerions/metricman)

It is just meta package which depends on [xerions/exometer](https://github.com/xerions/exometer) and configures some VM metrics like this:

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

## Dependencies tree

    xerions/metricman 
    `--> xerions/exometer
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
         `--> travelping/exometer_influxdb
              `--> Feuerlabs/exometer_core
              `--> benoitc/hackney
              |    `--> benoitc/erlang-idna
              |    `--> benoitc/mimerl
              |    `--> certifi/erlang-certifi
              |    `--> deadtrickster/ssl_verify_hostname

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
    metricman_config = "deps/metricman/config/config.exs"
    if File.exists? metricman_config do
        import_config "../" <> metricman_config
    end
   ```

4. And you can add your own exometer reporter in your config.exs:

    ```elixir
    config :exometer, :report,
        reporters: [
            {:exometer_report_graphite, [{:host, 'localhost'},
                                         {:port, 2003},
                                         {:api_key, 'exometer'}]}
        ]
    ```

    or for InfluxDB you can use conform config:

    ```
    influx.db = http://127.0.0.1:8086/default_db
    influx.tags = node:node_name,region:de
    ```

    See [this](https://github.com/Feuerlabs/exometer/blob/master/doc/README.md#configuring-reporter-plugins) for more information about configuring the reportes plugins.
