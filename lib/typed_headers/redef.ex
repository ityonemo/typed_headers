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

  @spec rebuild_code(:def | :defp, atom, list,  nil | [Macro.t], Macro.t, Macro.t) :: Macro.t
  defp rebuild_code(macro, fn_name, meta, nil, retval_type, block) do
    rebuild_code(macro, fn_name, meta, [], retval_type, block)
  end
  defp rebuild_code(macro, fn_name, meta, params, retval_type, block) do
    header = {fn_name, meta, Enum.map(params, &naked_params/1)}

    finalized_block = block
    |> inject_param_checks(Enum.flat_map(params, &param_checks/1))
    |> inject_retval_check(fn_name, retval_type)

    quote do
      Kernel.unquote(macro)(unquote(header), unquote(finalized_block))
    end
  end

  @spec naked_params(Macro.t) :: Macro.t
  defp naked_params({@t, _, [varinfo, _typeinfo]}), do: varinfo
  defp naked_params(varinfo), do: varinfo

  @full_context [context: Elixir, import: Kernel]

  defp param_checks({@t, _, [_variable, {type, _, _}]}) when type in @noops, do: []
  defp param_checks({@t, _, [variable, typespec]}) do
    die = quote do
      raise FunctionClauseError
    end
    lambda = Typespec.to_lambda(typespec, die)
    [quote do
      param_check = unquote(lambda)
      param_check.(unquote(variable))
    end]
  end
  defp param_checks(_), do: []

  defp inject_param_checks([do: {:__block__, meta, terms}], checks) do
    [do: {:__block__, meta, checks ++ terms}]
  end
  defp inject_param_checks([do: term], checks) do
    [do: {:__block__, [], checks ++ [term]}]
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
