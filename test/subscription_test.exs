defmodule MetricmanSubscribtionTest do

  @opts1 expose: [:influx]
  @opts2 expose: [:influx, :http]

  defmodule TestModule do
    use Metricman.Subscription

    @opts1 expose: [:influx]
    @opts2 expose: [:influx, :http]

    scope [:ipPools], @opts1 do
      map [:used],  [:ippools, :ip, :total, :used]
      map [:total], [:ippools, :ip, :total, :total], @opts2
      scope ['$country'] do
        scope [:region, "$region"] do # it is posible to use list and string as variable name
          map [:used],  [:ippools, :ip, '$country', '$region', :used]
          map [:total], [:ippools, :ip, "$country", "$region", :total]
          map [:func], [:ippools, :ip, "$country", "$region", :func]
        end
        map [:used],  [:ippools, :ip, '$country', :used]
        map [:total], [:ippools, :ip, '$country', :total]
        map [:req], [:ippools, :ip, "$country", :req], datapoints: [:max, :min]
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
    :exometer.new([:ippools, :ip, :ru, :req], :histogram)
    :exometer.new([:ippools, :ip, :ru, :nsk, :func], 
                  {:function, __MODULE__, :test_func, [], :proplist, [:value, :value2]}, [])
    on_exit fn ->
      for {name, _} <- :exometer.get_values([:ippools]), do: :exometer.delete(name)
    end
  end

  def test_func(), do: [value: 1]


  test "get not found" do
    assert {:error, :not_found} == TestModule.get([:macpools, :mac, :mactotal, :used], :counter)
  end

  test "get flat" do
    assert {:ok, {[:ipPools, :used], [:value], @opts1}} == TestModule.get([:ippools, :ip, :total, :used], :counter)
    assert {:ok, {[:ipPools, :total], [:value], @opts2}} == TestModule.get([:ippools, :ip, :total, :total], :counter)
  end

  test "get nested" do
    assert {:ok, {[:ipPools, :de, :used], [:value], @opts1}} == TestModule.get([:ippools, :ip, :de, :used], :counter)
    assert {:ok, {[:ipPools, :de, :total], [:value], @opts1}} == TestModule.get([:ippools, :ip, :de, :total], :counter)
    assert {:ok, {[:ipPools, :ru, :used], [:value], @opts1}} == TestModule.get([:ippools, :ip, :ru, :used], :counter)
    assert {:ok, {[:ipPools, :ru, :total], [:value], @opts1}} == TestModule.get([:ippools, :ip, :ru, :total], :counter)
  end

  test "get nested with overrided datapoints" do
    assert {:ok, {name, [:max, :min], opts}} = TestModule.get([:ippools, :ip, :ru, :req], :histogram)
    assert [:ipPools, :ru, :req] == name
    assert [:max, :min] == opts[:datapoints]
    assert [:influx] == opts[:expose]
  end

  test "get more nested" do
    assert {:ok, {[:ipPools, :ru, :region, :nsk, :used], [:value], @opts1}} 
           == TestModule.get([:ippools, :ip, :ru, :nsk, :used], :counter)
    assert {:ok, {[:ipPools, :ru, :region, :nsk, :total], [:value], @opts1}} 
           == TestModule.get([:ippools, :ip, :ru, :nsk, :total], :counter)
    assert {:ok, {[:ipPools, :ru, :region, :nsk, :func], [:value, :value2], @opts1}} 
           == TestModule.get([:ippools, :ip, :ru, :nsk, :func], :function)
  end
end
