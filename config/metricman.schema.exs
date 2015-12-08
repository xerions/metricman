[
  mappings: [
    "influx.db": [
      doc: """
      Influxdb configuration in form of <host>[:<port>]/<database>
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
    ]
  ],
  translations: [
    "influx.db": fn
      _mapping, "false", acc -> (acc || [])
      _mapping, db, acc ->
        case URI.parse(db) do
          %URI{scheme: protocol, host: host, port: port, path: "/" <> path} ->
            params = Access.get(acc || [exometer_report_influxdb: []], :exometer_report_influxdb)
            [exometer_report_influxdb: params ++ [protocol: protocol |> String.to_atom,
                                                  host: host, port: port, db: path]]
          _ ->
            IO.puts("Unsupported URI for InfluxDB: #{db}")
            exit(1)
        end
      _, db, _ ->
        IO.puts("Unsupported URI for InfluxDB: #{db}")
        exit(1)
    end,
    "influx.tags": fn
      _mapping, [""], acc -> (acc || [])
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
    end
  ]
]
