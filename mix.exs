defmodule Metricman.Mixfile do
  use Mix.Project

  def project do
    [app: :metricman,
     version: "0.0.1",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(Mix.env)]
  end

  def application do
    [applications: [:logger, :exometer]]
  end

  defp deps(_) do
    [
     {:lager, "~> 2.1.1", override: true},
     {:exometer, github: "Feuerlabs/exometer"},
     {:meck, "~> 0.8.2", override: true},
     {:exometer_core, github: "Feuerlabs/exometer_core", branch: "master", override: true},
     {:edown, github: "uwiger/edown", branch: "master", override: true},
     {:mock, github: "jjh42/mock"}]
  end
end
