defmodule MetricmanSubscribtionTest do
  defmodule TestModule do
    use Metricman.Subscription

    scope [:ipPools] do
      map [:used],  [:ippools, :ip, :total, :used]
      map [:total], [:ippools, :ip, :total, :total]
      scope ['$country'] do
        scope [:region, "$city"] do # it is posible to use list and string as variable name
          map [:used],  [:ippools, :ip, '$country', '$city', :used]
          map [:total], [:ippools, :ip, "$country", "$city", :total]
        end
        map [:used],  [:ippools, :ip, '$country', :used]
        map [:total], [:ippools, :ip, '$country', :total]
      end
    end
  end

  use ExUnit.Case

  setup_all do
    :exometer.new([:ippools, :ip, :total, :used], :counter)
    :exometer.new([:ippools, :ip, :total, :total], :counter)
    :exometer.new([:ippools, :ip, :de, :used], :counter)
    :exometer.new([:ippools, :ip, :de, :total], :counter)
    :exometer.new([:ippools, :ip, :ru, :used], :counter)
    :exometer.new([:ippools, :ip, :ru, :total], :counter)
    :exometer.new([:ippools, :ip, :ru, :nsk, :used], :counter)
    :exometer.new([:ippools, :ip, :ru, :nsk, :total], :counter)
    on_exit fn ->
      for {name, _} <- :exometer.get_values([:ippools]), do: :exometer.delete(name)
    end
  end

  test "get not found" do
    assert {:error, :not_found} == TestModule.get([:macpools, :mac, :mactotal, :used], :counter)
  end

  test "get flat" do
    assert {:ok, {[:ipPools, :used], [:value]}} == TestModule.get([:ippools, :ip, :total, :used], :counter)
    assert {:ok, {[:ipPools, :total], [:value]}} == TestModule.get([:ippools, :ip, :total, :total], :counter)
  end

  test "get nested" do
    assert {:ok, {[:ipPools, :de, :used], [:value]}} == TestModule.get([:ippools, :ip, :de, :used], :counter)
    assert {:ok, {[:ipPools, :de, :total], [:value]}} == TestModule.get([:ippools, :ip, :de, :total], :counter)
    assert {:ok, {[:ipPools, :ru, :used], [:value]}} == TestModule.get([:ippools, :ip, :ru, :used], :counter)
    assert {:ok, {[:ipPools, :ru, :total], [:value]}} == TestModule.get([:ippools, :ip, :ru, :total], :counter)
  end

  test "get more nested" do
    assert {:ok, {[:ipPools, :ru, :region, :nsk, :used], [:value]}} == TestModule.get([:ippools, :ip, :ru, :nsk, :used], :counter)
    assert {:ok, {[:ipPools, :ru, :region, :nsk, :total], [:value]}} == TestModule.get([:ippools, :ip, :ru, :nsk, :total], :counter)
  end
end
