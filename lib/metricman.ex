defmodule Metricman do
  use Application

  @doc false
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = []

    :exometer.update([:erlang, :beam, :start_time], timestamp())

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

  def update_uptime do
    {:ok, [{:value, start_time}, _ ]} = :exometer.get_value([:erlang, :beam, :start_time])
    uptime = timestamp() - start_time
    [value: round(uptime)]
  end

  def timestamp() do
    try do
      :erlang.system_time(:milli_seconds)
    rescue # fallback for erlang 17 and older
      _error ->
        {mega_secs, secs, micro_secs} = :os.timestamp()
        1000 * (secs + (mega_secs * 1000000) + (micro_secs / 10000000))
    end
  end

end
