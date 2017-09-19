defmodule Metricman.Mixfile do
  use Mix.Project

  def project do
    [app: :metricman,
     version: "1.4.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(Mix.env)]
  end

  def application do
    [applications: [:exometer_fetch, :exometer_influxdb],
     mod: {Metricman, []}]
  end

  defp deps(_) do
    [{:exometer_influxdb, "~> 0.5.7"},
     {:exometer_fetch,    "~> 0.1.0"},
     {:recon,             "~> 2.2.1"}]
  end
end
