defmodule Metricman do
  use Application

  @doc false
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = []

    subscribe_all

    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end

  def garbage_collection do
    {number_of_gcs, words_reclaimed, _} = :erlang.statistics(:garbage_collection)
    [number_of_gcs: number_of_gcs, words_reclaimed: words_reclaimed]
  end

  def io do
    {{:input, input}, {:output, output}} = :erlang.statistics(:io)
    [input: input, output: output]
  end

  def subscribe_all do
    for {reporter, _} <- :exometer_report.list_reporters do
      for {name, data_point, time} <- Application.get_env(:metricman, :subscriptions) do
        :exometer_report.subscribe(reporter, name, data_point, time)
      end
    end
  end
end
