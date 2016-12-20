defmodule Metricman.Mixfile do
  use Mix.Project

  def project do
    [app: :metricman,
     version: "1.4.0",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(Mix.env)]
  end

  def application do
    [applications: [:exometer_fetch, :exometer_influxdb],
     mod: {Metricman, []}]
  end

  defp deps(_) do
    [{:meck, "~> 0.8.2", override: true},

     {:exometer_influxdb, github: "travelping/exometer_influxdb", branch: "master"},
     {:exometer_fetch, github: "travelping/exometer_fetch", branch: "master"},

     {:recon, "~> 2.2.1"},
     {:setup, github: "uwiger/setup", branch: "master", override: true, compile: "make"},
     {:edown, github: "uwiger/edown", branch: "master", override: true},
     {:lager,         github: "basho/lager", tag: "3.2.2", override: true}
   ]
  end
end
