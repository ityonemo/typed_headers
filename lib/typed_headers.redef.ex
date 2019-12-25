defmodule TypedHeaders.Redef do

  @t :"::"

  defmacro defp({@t, _, [{fn_name, meta, params}, retval_type]}, block) do
    rebuild_code(:def, fn_name, meta, params, retval_type, block)
  end

  defmacro defp({fn_name, meta, params}, block) do
    rebuild_code(:def, fn_name, meta, params, nil, block)
  end

  defmacro def({@t, _, [{fn_name, meta, params}, retval_type]}, block) do
    rebuild_code(:def, fn_name, meta, params, retval_type, block)
  end

  defmacro def({fn_name, meta, params}, block) do
    rebuild_code(:def, fn_name, meta, params, nil, block)
  end

  def rebuild_code(macro, fn_name, meta, params, retval_type, block) do
    naked_params = Enum.map(params, &naked_params/1)
    header = case Enum.flat_map(params, &when_statements/1) do
      [] ->
        {fn_name, meta, naked_params}
      lst when is_list(lst) ->
        {:when, [context: Elixir], [{fn_name, meta, naked_params}, list_to_ands(lst)]}
    end

    checked_block = if retval_type do
      inject_check(block, fn_name, retval_type)
    else
      block
    end

    quote do
      Kernel.unquote(macro)(unquote(header), unquote(checked_block))
    end
  end

  defp naked_params({@t, _, [varinfo, _typeinfo]}), do: varinfo
  defp naked_params(varinfo), do: varinfo

  @typefn %{
    integer:   :is_integer,
    float:     :is_float,
    number:    :is_number,
    pid:       :is_pid,
    reference: :is_reference,
    boolean:   :is_boolean,
    atom:      :is_atom,
    tuple:     :is_tuple,
    list:      :is_list,
    map:       :is_map
  }
  @builtins Map.keys(@typefn)
  @full_context [context: Elixir, import: Kernel]

  defp when_statements({@t, _, [_, {:any, _, _}]}), do: []
  defp when_statements({@t, _, [varinfo, {type, _, _}]}) when type in @builtins do
    [{@typefn[type], @full_context, [varinfo]}]
  end
  defp when_statements({@t, _, [varinfo, {:struct, _, _}]}) do
    [dot_call(:erlang, :is_map_key, [:__struct__, varinfo])]
  end
  defp when_statements({@t, _, [varinfo, {:neg_integer, _, _}]}) do
    [{@typefn[:integer], @full_context, [varinfo]}, {:<, @full_context, [varinfo, 0]}]
  end
  defp when_statements({@t, _, [varinfo, {:non_neg_integer, _, _}]}) do
    [{@typefn[:integer], @full_context, [varinfo]}, {:>=, @full_context, [varinfo, 0]}]
  end
  defp when_statements({@t, _, [varinfo, {:pos_integer, _, _}]}) do
    [{@typefn[:integer], @full_context, [varinfo]}, {:>, @full_context, [varinfo, 0]}]
  end
  defp when_statements({@t, _, [varinfo, fixval]}) when is_integer(fixval) do
    [{@typefn[:integer], @full_context, [varinfo]}, {:==, @full_context, [varinfo, fixval]}]
  end
  defp when_statements({@t, _, [varinfo, {:.., _, [a, b]}]}) when is_integer(a) and is_integer(b) do
    [
      {@typefn[:integer], @full_context, [varinfo]},
      {:>=, @full_context, [varinfo, a]},
      {:<=, @full_context, [varinfo, b]}
    ]
  end
  defp when_statements({_varinfo, _, atom}) when is_atom(atom), do: []

  defp inject_check([do: term], fn_name, {type, _, _}) when type in @builtins do
    result = quote do var!(result) end
    guard = {:when, [], [result, {@typefn[type], @full_context, [result]}]}
    inject_check(term, fn_name, type, guard)
  end
  defp inject_check([do: term], fn_name, {:struct, _, _}) do
    result = quote do var!(result) end
    guard = {:when, [], [result, dot_call(:erlang, :is_map_key, [:__struct__, result])]}
    inject_check(term, fn_name, :struct, guard)
  end

  defp inject_check(term, fn_name, type, guard) do
    new_directive = quote do
      case unquote(term) do
        unquote(guard) -> var!(result)
        value -> raise RuntimeError, message: "function #{unquote(fn_name)} expects type #{unquote(type)}, got #{inspect value}"
      end
    end
    [do: new_directive]
  end

  defp dot_call(module, fun, vars), do: {{:., [], [module, fun]}, [], vars}

  defp list_to_ands([a, b]) do
    {:and, @full_context, [a, b]}
  end
  defp list_to_ands([a]), do: a
  defp list_to_ands(lst) do
    half_length = div(Enum.count(lst), 2)
    {lst_1, lst_2} = Enum.split(lst, half_length)
    {:and, @full_context, [list_to_ands(lst_1), list_to_ands(lst_2)]}
  end
end
