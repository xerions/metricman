[
  mappings: [
    "metrics.influx.db": [
      doc: """
      Influxdb configuration in form of <shema>://<host>[:<port>]/<database>
      """,
      to: "exometer_core.report.reporters.exometer_report_influxdb.db",
      datatype: :binary,
      default: "false"
    ],
    "metrics.influx.tags": [
      doc: """
      Influxdb additional tags for each metric in form of <key>:<value>,...
      """,
      to: "exometer_core.report.reporters.exometer_report_influxdb.tags",
      datatype: [list: :binary],
      default: []
    ],
    "metrics.influx.batch_window_size": [
      doc: """
      Set window size in ms for batch sending.
      This means reported will collect measurements within this interval and send all measurements in one packet.
      """,
      to: "exometer_core.report.reporters.exometer_report_influxdb.batch_window_size",
      datatype: :integer,
      default: 0
    ],
    "metrics.influx.autosubscribe": [
      to: "exometer_core.report.reporters.exometer_report_influxdb.autosubscribe",
      datatype: [enum: [true, false]],
      default: true
    ],
    "metrics.fetch.autosubscribe": [
      to: "exometer_core.report.reporters.exometer_report_fetch.autosubscribe",
      datatype: [enum: [true, false]],
      default: true
    ],
  ],
  transforms: [
    "exometer_core.report.reporters": fn table ->
      db = case Conform.Conf.get(table, "exometer_core.report.reporters.exometer_report_influxdb.db") do
             [{_, db}] when is_binary(db) and db != "false" ->
               case URI.parse(db) do
                 %URI{scheme: protocol, host: host, port: port} = uri ->
                   db = case protocol do
                          "udp" -> []
                          http when http in ["http", "https"] ->
                            "/" <> path = uri.path
                            [db: path]
                          _ ->
                             exit("Unsupported URI for InfluxDB: #{db}")
                        end
                   [protocol: protocol |> String.to_atom, host: host, port: port] ++ db
               end
             _ ->
               [db: "false"]
           end
      autosubscribe = case Conform.Conf.get(table, "exometer_core.report.reporters.exometer_report_influxdb.autosubscribe") do
                        [{_, true}] ->
                          [autosubscribe: true]
                        _ ->
                          []
                      end
      tags = case Conform.Conf.get(table, "exometer_core.report.reporters.exometer_report_influxdb.tags") do
               [{_, []}] ->
                 []
               [{_, tags}] ->
                 tags = for tag <- tags do
                   case String.split(tag, ":") do
                     [key, value] -> {key |> String.to_atom, value}
                     _ -> exit("Unsupported tags for InfluxDB: #{inspect tags}")

                   end
                 end
                 [tags: tags]
            end
      batch_window_size = case Conform.Conf.get(table, "exometer_core.report.reporters.exometer_report_influxdb.batch_window_size") do
                            [{_, []}] ->
                              []
                            [{_, window_size}] ->
                              if not is_integer(window_size) do
                                exit("Unsupported batch_window_size for InfluxDB: #{inspect window_size}")
                              end
                             [batch_window_size: window_size]
                          end
      fetch_reporter = case Conform.Conf.get(table, "exometer_core.report.reporters.exometer_report_fetch.autosubscribe") do
                        [{_, true}] ->
                          [exometer_report_fetch: [autosubscribe: true]]
                        _ ->
                          [exometer_report_fetch: [autosubscribe: false]]
                      end
      db = if db != [db: "false"] do
             [exometer_report_influxdb: db ++ tags ++ batch_window_size ++ autosubscribe]
           else
             []
           end
      :ets.match_delete(table, {['exometer_core', 'report', 'reporters' | :_], :_})
      [db, fetch_reporter] |> List.flatten
  end
  ]
]
