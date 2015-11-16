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

  test "home dir to /tmp" do
    assert (System.tmp_dir! |> String.to_char_list) == Application.get_env(:setup, :home)
  end
end
