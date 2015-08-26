defmodule MetricmanTest do
  use ExUnit.Case

  test "list reporters" do
    assert length(:exometer_report.list_reporters) == 1
  end

  test "list metrics" do
    {:ok, metrics} = :exometer_report.list_metrics
    assert length(metrics) > 0
  end

  test "list subscriptions" do
    assert length(:exometer_report.list_subscriptions(:exometer_report_graphite)) > 0
  end

  test "home dir to /dev/null" do
    assert '/dev/null' == Application.get_env(:setup, :home)
  end
end
