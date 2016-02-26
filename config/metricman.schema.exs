[
  mappings: [
    "influx.db": [
      doc: """
      Influxdb configuration in form of <shema>://<host>[:<port>]/<database>
      """,
      to: "exometer_core.report.reporters",
      datatype: :binary,
      default: false
    ],
    "influx.tags": [
      doc: """
      Influxdb additional tags for each metric in form of <key>:<value>,...
      """,
      to: "exometer_core.report.reporters",
      datatype: [list: :binary],
      default: ""
    ],
    "influx.batch_window_size": [
      doc: """
      Set window size in ms for batch sending.
      This means reported will collect measurements within this interval and send all measurements in one packet.
      """,
      to: "exometer_core.report.reporters",
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
            exit("Unsupported URI for InfluxDB: #{db}")
        end
      _, db, _ ->
        exit("Unsupported URI for InfluxDB: #{db}")
    end,
    "influx.tags": fn
      _mapping, [""], acc -> acc
      _mapping, _, nil -> nil
      _mapping, tags, acc ->
        tags = for tag <- tags do
          case String.split(tag, ":") do
            [key, value] -> {key |> String.to_atom, value}
            _ ->
              exit("Unsupported tags for InfluxDB: #{inspect tags}")
          end
        end
        params = Access.get(acc || [exometer_report_influxdb: []], :exometer_report_influxdb)
        [exometer_report_influxdb: params ++ [tags: tags]]
      _, tags, _ ->
        exit("Unsupported tags for InfluxDB: #{inspect tags}")
    end,
    "influx.batch_window_size": fn
      _mapping, _, nil -> []
      _mapping, window_size, acc ->
        if not is_integer(window_size) do
          exit("Unsupported batch_window_size for InfluxDB: #{inspect window_size}")
        end
        params = Access.get(acc || [exometer_report_influxdb: []], :exometer_report_influxdb)
        [exometer_report_influxdb: params ++ [batch_window_size: window_size]]
    end
  ]
]
