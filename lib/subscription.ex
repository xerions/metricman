defmodule Metricman.Subscription do
  @moduledoc """
    Helper for defined metrics mapping which can be used together with subscription modules 
    from exometer_influxdb or exometer_fetch.
    
    ## Example

        defmodule MetrcisMapping do
          use Metricman.Subscription
          
          scope [:ipPools], opts \\ [] do
            map [:used],  [:ippools, :ip, :total, :used], opts \\ []
            map [:total], [:ippools, :ip, :total, :total], opts \\ []
            scope ["$country"] do
              map [:used],  [:ippools, :ip, "$country", :used], opts \\ []
              map [:total], [:ippools, :ip, "$country", :total], opts \\ []
            end
          end
        end

    After compiling here will be available `MetrcisMapping.get/2` function 
    which can be used for geting external id by internal id and its type.
  """

  @doc false
  defmacro __using__(_) do
    quote do
      @path []
      @opts []
      import Metricman.Subscription
      @before_compile Metricman.Subscription
    end
  end

  @doc false
  defmacro __before_compile__(_env) do
    quote do 
      def get(_, _), do: {:error, :not_found}
    end
  end

  @doc """
  Defines a scope in which maps or other scopes can be nested.

  ## Examples

      scope [:ipPools], opts \\ [] do
        map [:used],  [:ippools, :ip, :total, :used]
      end

  It generates `get([:ippools. :ip, :total, :used], metric_type)` function which returns
  `{[:ipPools, :used], datapoints, opts}` where `datapoints` is related to `metric_type`:

    * :histogram -> [95, 99, max]
    * :gauge -> [:value]
    * :context -> [:value]
    * :function -> returns all datapoints registered for this function

  `opts` is keyword list and nested options will be merged with scope. 
  There are the following special options:

    * :detapoints - override default datapoints for for entry.  

  ### Variables

  Variables are available. Each variable should be string or characters list started with $ symbol:

      scope [:ipPools, '$country'] do
        map [:used],  [:ippools, :ip, '$country', :used]
      end

  It generates `get([:ippools. :ip, country, :used], metric_type)` function which returns
  `{[:ipPools, country, :used], datapoint}`. Examples:

    get([:ippools, :ip, :de, :used], :counter) -> {[:ipPools, :de, :used], [:value], opts}
    get([:ippools, :ip, :ru, :used], :counter) -> {[:ipPools, :ru, :used], [:value], opts}

  """
  defmacro scope(path, opts \\ [], do: context) do
    quote do
      old_path = @path
      old_opts = @opts
      Module.put_attribute(__MODULE__, :path, @path ++ unquote(path))
      Module.put_attribute(__MODULE__, :opts, Keyword.merge(old_opts, unquote(opts)))
      unquote(context)
      Module.put_attribute(__MODULE__, :path, old_path)
      Module.put_attribute(__MODULE__, :opts, old_opts)
    end
  end

  @doc """
  Generate function for mapping. See `scope/2` for more information.
  """
  defmacro map(id, exo_id, opts \\ []) do
    exo_id_for_match = List.foldl(exo_id, [],
                                  fn ([?$ | id], ids) -> ids ++ [{id |> to_downcased_atom, [], Elixir}]
                                     ("$" <> id, ids) -> ids ++ [{id |> to_downcased_atom, [], Elixir}]
                                     (id, ids) -> ids ++ [id] end)
    vars = List.foldl(exo_id, [], 
                      fn ([?$ | id], acc) -> acc ++ [id |> to_downcased_atom]
                         ("$" <>  id, acc) -> acc ++ [id |> to_downcased_atom]
                         (_, acc) ->  acc ++ [:_]
                      end)
    quote do 
      def get(unquote(exo_id_for_match), metric_type) do
        vars = unquote(vars) 
               |> Enum.zip(unquote(exo_id_for_match)) 
               |> Enum.filter(fn({x, _}) -> x != :_ end)
        path = List.foldl(@path ++ unquote(id), [], 
                          fn ([?$ | id], acc) -> acc ++ [id |> to_downcased_atom]
                             ("$" <> id, acc) -> acc ++ [id |> to_downcased_atom]
                             (id, acc) ->  acc ++ [id]
                          end)
        opts = Keyword.merge(@opts, unquote(opts))
        path |> result(metric_type, unquote(exo_id), vars, opts)  
      end
    end
  end

  @doc false
  def to_downcased_atom(list) when is_list(list), 
    do: list |> List.to_string |> String.downcase |> String.to_atom
  def to_downcased_atom(bin) when is_binary(bin), 
    do: bin |> String.downcase |> String.to_atom

  @doc false
  def result(nil, _metric_type, _exo_id, _vars, _opts), do: {:error, :not_found}
  def result(id, metric_type, exo_id, [], opts), 
    do: id |> check_metric_type(metric_type, exo_id, opts)
  def result(id, metric_type, exo_id, vars, opts), do:
    Enum.map_reduce(vars, id, 
                    fn({key, val}, acc) ->
                      case Enum.find_index(id, fn k -> k == key end) do
                        nil   -> {nil, acc}
                        index -> {key, List.update_at(acc, index, fn _ -> val end)}
                      end
                    end) 
    |> elem(1) 
    |> check_metric_type(metric_type, exo_id, opts)

  defp check_metric_type(id, :function, exo_id, opts) do
    case :exometer.get_value(exo_id) do
      {:error, reason} ->
        {:error, {:exometer_lookup, reason}}
      {:ok, [_head | _] = datapoints} ->
        {:ok, {id, datapoints(opts, Keyword.keys(datapoints)), opts}}
      _ ->
        {:error, {:no_datapoints, id, exo_id}}
    end
  end
  defp check_metric_type(id, :histogram, _exo_id, opts), do:
    {:ok, {id, datapoints(opts, [95, 99, :max]), opts}}
  defp check_metric_type(id, :gauge, _exo_id, opts), do:
    {:ok, {id, datapoints(opts, [:value]), opts}}
  defp check_metric_type(id, :counter, _exo_id, opts), do:
    {:ok, {id, datapoints(opts, [:value]), opts}}
  defp check_metric_type(_, _, _, _), do: {:error, :not_found}

  defp datapoints(opts, default) do
    case opts[:datapoints] do
      nil -> default
      datapoints -> datapoints
    end
  end
end
