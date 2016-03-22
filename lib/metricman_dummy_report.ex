defmodule Metricman.DummyReporter do
  def exometer_init(_opts), do: {:ok, []}
  def exometer_subscribe(_metric, _datapoint, _extra, _interval, st), do: {:ok, st}
  def exometer_unsubscribe(_metric, _dataPoint, _extra, st), do: {:ok, st}
  def exometer_report(_metric, _datapoint, _extra, _value, st), do: {:ok, st}
  def exometer_call(_unknown, _from, st), do: {:ok, st}
  def exometer_cast(_unknown, st), do: {:ok, st}
  def exometer_info(_unknown, st), do: {:ok, st}
  def exometer_newentry(_entry, st), do: {:ok, st}
  def exometer_setopts(_metric, _options, _status, st), do: {:ok, st}
  def exometer_terminate(_, _), do: :ignore
end
