defmodule TypedHeaders.Redef do

  @t :"::"
  @noops [:any, :term]

  alias TypedHeaders.Typespec
  alias TypedHeaders.List

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

  # substitute [] for nil, for zero-arity functions without params parens
  def rebuild_code(macro, fn_name, meta, nil, retval_type, block) do
    rebuild_code(macro, fn_name, meta, [], retval_type, block)
  end
  def rebuild_code(macro, fn_name, meta, params, retval_type, block) do
    naked_params = Enum.map(params, &naked_params/1)
    header = case Enum.flat_map(params, &when_statements/1) do
      [] ->
        {fn_name, meta, naked_params}
      lst when is_list(lst) ->
        {:when, [context: Elixir], [{fn_name, meta, naked_params}, list_to_ands(lst)]}
    end

    pre_statements = Enum.flat_map(params, &pre_statements/1)

    finalized_block = block
    |> inject_prestatements(pre_statements)
    |> inject_check(fn_name, retval_type)

    quote do
      Kernel.unquote(macro)(unquote(header), unquote(finalized_block))
    end
  end

  defp naked_params({@t, _, [varinfo, _typeinfo]}), do: varinfo
  defp naked_params(varinfo), do: varinfo

  @full_context [context: Elixir, import: Kernel]

  # no terms
  defp when_statements({@t, _, [_, {no_op, _, _}]}) when no_op in @noops, do: []
  # general type data forms
  defp when_statements({@t, _, [variable, typedata]}) do
    [Typespec.to_guard(typedata, variable)]
  end
  # no type signature, generates no content.
  defp when_statements({_varinfo, _, atom}) when is_atom(atom), do: []

  @list_types List.types
  @module_types TypedHeaders.Module.types

  # filter functions
  defp pre_statements({@t, _, [_variable, [{:->, _, _}]]}), do: []
  defp pre_statements({@t, _, [variable, [{:..., _, _}]]}) do
    List.pre_checks({:nonempty_list, @full_context, nil}, variable)
  end
  defp pre_statements({@t, _, [variable, [type, {:..., _, _}]]}) do
    List.pre_checks({:nonempty_list, @full_context, [type]}, variable)
  end
  defp pre_statements({@t, _, [variable, spec = [{atom, _} | _]]}) when is_atom(atom) do
    List.pre_checks(spec, variable)
  end
  defp pre_statements({@t, _, [variable, [spec]]}) do
    List.pre_checks({:list, @full_context, [spec]}, variable)
  end
  defp pre_statements({@t, _, [variable, spec = {type, _, _}]}) when type in @list_types do
    List.pre_checks(spec, variable)
  end
  defp pre_statements({@t, _, [variable, spec = {type, _, _}]}) when type in @module_types do
    TypedHeaders.Module.pre_checks(spec, variable)
  end
  defp pre_statements(_), do: []

  defp inject_prestatements([do: {:__block__, meta, terms}], prestatements) do
    [do: {:__block__, meta, prestatements ++ terms}]
  end
  defp inject_prestatements([do: term], prestatements) do
    [do: {:__block__, [], prestatements ++ [term]}]
  end

  defp post_checks([{:->, _, _}], _, _, _), do: []
  defp post_checks([{:..., _, _}], fn_name, type, value) do
    List.post_checks({:nonempty_list, @full_context, nil}, fn_name, type, value)
  end
  defp post_checks([t, {:..., _, _}], fn_name, type, value) do
    List.post_checks({:nonempty_list, @full_context, [t]}, fn_name, type, value)
  end
  defp post_checks(spec = [{atom, _} | _], fn_name, type, value) when is_atom(atom) do
    List.post_checks(spec, fn_name, type, value)
  end
  defp post_checks([typedata], fn_name, type, value) do
    List.post_checks({:list, [], [typedata]}, fn_name, type, value)
  end
  defp post_checks(spec = {list_type, _, _}, fn_name, type, value)
      when list_type in @list_types do
    List.post_checks(spec, fn_name, type, value)
  end
  defp post_checks(spec = {module_type, _, _}, fn_name, type, value)
      when module_type in @module_types do
    TypedHeaders.Module.post_checks(spec, fn_name, type, value)
  end
  defp post_checks(_, _, _, _), do: []

  defp inject_check([do: term], _fn_name, nil), do: [do: term]
  defp inject_check([do: term], _fn_name, {noop, _, _}) when noop in @noops, do: [do: term]
  defp inject_check([do: term], fn_name, typedata) do
    typestr = Typespec.to_string(typedata)
    inject_check(term,
      fn_name,
      typestr,
      post_checks(typedata, fn_name, typestr, quote do var!(result) end),
      when_result(typedata))
  end

  defp inject_check(term, fn_name, type, post_checks, guard) do
    new_directive = quote do
      case unquote(term) do
        unquote(guard) ->
          unquote_splicing(post_checks)
          var!(result)
        value -> raise RuntimeError, message: "function #{unquote(fn_name)} expects type #{unquote(type)}, got #{inspect value}"
      end
    end
    [do: new_directive]
  end

  defp when_result(typedata) do
    result = quote do var!(result) end
    {:when, [], [result, Typespec.to_guard(typedata, result)]}
  end

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
