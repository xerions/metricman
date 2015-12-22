[
  mappings: [
    "influx.db": [
      doc: """
      Influxdb configuration in form of <shema>://<host>[:<port>]/<database>
      """,
      to: "exometer.report.reporters",
      datatype: :binary,
      default: false
    ],
    "influx.tags": [
      doc: """
      Influxdb additional tags for each metric in form of <key>:<value>,...
      """,
      to: "exometer.report.reporters",
      datatype: [list: :binary],
      default: ""
    ],
    "influx.batch_window_size": [
      doc: """
      Set window size in ms for batch sending.
      This means reported will collect measurements within this interval and send all measurements in one packet.
      """,
      to: "exometer.report.reporters",
      datatype: :integer,
      default: 0
    ]
  ],
  translations: [
    "influx.db": fn
      _mapping, "false", acc -> acc
      _mapping, db, acc ->
        case URI.parse(db) do
          %URI{scheme: protocol, host: host, port: port} = uri ->
            db = case protocol do
              "udp" -> []
              http when http in ["http", "https"] -> 
                "/" <> path = uri.path  
                [db: path]
            end
            params = Access.get(acc || [exometer_report_influxdb: []], :exometer_report_influxdb)
            [exometer_report_influxdb: params ++ [protocol: protocol |> String.to_atom,
                                                  host: host, port: port] ++ db]
          _ ->
            IO.puts("Unsupported URI for InfluxDB: #{db}")
            exit(1)
        end
      _, db, _ ->
        IO.puts("Unsupported URI for InfluxDB: #{db}")
        exit(1)
    end,
    "influx.tags": fn
      _mapping, [""], acc -> acc
      _mapping, _, nil -> nil
      _mapping, tags, acc ->
        tags = for tag <- tags do
          case String.split(tag, ":") do
            [key, value] -> {key |> String.to_atom, value}
            _ ->
              IO.puts("Unsupported tags for InfluxDB: #{inspect tags}")
              exit(1)
          end
        end
        params = Access.get(acc || [exometer_report_influxdb: []], :exometer_report_influxdb)
        [exometer_report_influxdb: params ++ [tags: tags]]
      _, tags, _ ->
        IO.puts("Unsupported tags for InfluxDB: #{inspect tags}")
        exit(1)
    end,
    "influx.batch_window_size": fn
      _mapping, _, nil -> []
      _mapping, window_size, acc ->
        if not is_integer(window_size) do
          IO.puts("Unsupported batch_window_size for InfluxDB: #{inspect window_size}")
          exit(1)
        end
        params = Access.get(acc || [exometer_report_influxdb: []], :exometer_report_influxdb)
        [exometer_report_influxdb: params ++ [batch_window_size: window_size]]
    end
  ]
]
