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
    assert length(:exometer_report.list_subscriptions(:exometer_report_tty)) > 0
  end

  test "verify_directories false" do
    assert false == Application.get_env(:setup, :verify_directories)
  end
end
