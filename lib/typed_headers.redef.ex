defmodule TypedHeaders.Redef do

  @t :"::"

  defmacro def({@t, _, [{fn_name, meta, params}, retval_type]}, block) do
    naked_params = Enum.map(params, &naked_params/1)
    header = case Enum.flat_map(params, &when_statements/1) do
      [] ->
        {fn_name, meta, naked_params}
      [when_1] ->
        {:when, [context: Elixir], [{fn_name, meta, naked_params}, when_1]}
    end

    checked_block = inject_check(block, fn_name, retval_type)

    quote do
      Kernel.def(unquote(header), unquote(checked_block))
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

  defp when_statements({@t, _, [varinfo, {type, _, _}]}) when type in @builtins do
    [{@typefn[type], [context: Elixir, import: Kernel], [varinfo]}]
  end
  defp when_statements(_), do: []

  defp inject_check([do: term], fn_name, {type, _, _}) when type in @builtins do
    result = quote do var!(result) end
    guard = {:when, [], [result, {@typefn[type], [context: Elixir, import: Kernel], [result]}]}
    new_directive = quote do
      case unquote(term) do
        unquote(guard) -> var!(result)
        value -> raise RuntimeError, message: "function #{unquote(fn_name)} expects type #{unquote(type)}, got #{inspect value}"
      end
    end
    [do: new_directive]
  end

end
