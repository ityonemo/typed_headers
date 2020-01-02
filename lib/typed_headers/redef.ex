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
    |> inject_retval_check(fn_name, retval_type)

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
  defp pre_statements({@t, _, [variable, {:%{}, _, spec}]}) do
    TypedHeaders.Map.pre_checks(spec, variable)
  end
  defp pre_statements(_), do: []

  defp inject_prestatements([do: {:__block__, meta, terms}], prestatements) do
    [do: {:__block__, meta, prestatements ++ terms}]
  end
  defp inject_prestatements([do: term], prestatements) do
    [do: {:__block__, [], prestatements ++ [term]}]
  end

  defp inject_retval_check(block, _fn_name, nil), do: block
  defp inject_retval_check(block, _fn_name, {noop, _, _}) when noop in @noops, do: block
  defp inject_retval_check([do: inner_block], fn_name, typedata) do
    typestr = Typespec.to_string(typedata)
    die = quote do
      result_text = inspect(var!(result))
      raise RuntimeError, message: "function #{unquote(fn_name)} should return #{unquote typestr}, got: #{result_text}"
    end
    check = Typespec.to_lambda(typedata, die)
    [do: quote do
      var!(result) = (unquote(inner_block))
      retval_lambda = unquote(check)
      retval_lambda.(var!(result))
      var!(result)
    end]
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
