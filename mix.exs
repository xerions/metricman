defmodule Metricman.Mixfile do
  use Mix.Project

  def project do
    [app: :metricman,
     version: "1.2.1",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(Mix.env)]
  end

  def application do
    [applications: [:exometer_influxdb],
     mod: {Metricman, []}]
  end

  defp deps(_) do
    [{:lager, "~> 2.1.1", override: true},
     {:meck, "~> 0.8.2", override: true},

     {:exometer_influxdb, github: "travelping/exometer_influxdb", branch: "master"},

     {:goldrush, github: "DeadZen/goldrush", tag: "0.1.6", override: true},
     {:setup, github: "uwiger/setup", branch: "master", override: true},
     {:edown, github: "uwiger/edown", branch: "master", override: true}
   ]
  end
end
