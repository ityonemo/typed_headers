defmodule TypedHeaders.Redef do

  @t :"::"
  @noops [:any, :term]

  alias TypedHeaders.Typespec

  defmacro defp({@t, _, [{fn_name, meta, params}, retval_type]}, block) do
    rebuild_code(:def, __CALLER__, fn_name, meta, params, retval_type, block)
  end

  defmacro defp({fn_name, meta, params}, block) do
    rebuild_code(:def, __CALLER__, fn_name, meta, params, nil, block)
  end

  defmacro def({@t, _, [{fn_name, meta, params}, retval_type]}, block) do
    rebuild_code(:def, __CALLER__, fn_name, meta, params, retval_type, block)
  end

  defmacro def({fn_name, meta, params}, block) do
    rebuild_code(:def, __CALLER__, fn_name, meta, params, nil, block)
  end

  @spec rebuild_code(:def | :defp, Macro.Env.t, atom, list,  nil | [Macro.t], Macro.t, Macro.t) :: Macro.t
  defp rebuild_code(macro, caller, fn_name, meta, nil, retval_type, block) do
    rebuild_code(macro, caller, fn_name, meta, [], retval_type, block)
  end
  defp rebuild_code(macro, caller, fn_name, meta, params, retval_type, block) do
    header = {fn_name, meta, Enum.map(params, &naked_params/1)}

    desc = %{module: caller.module, function: fn_name, arity: length(params)}

    parameter_checks = params
    |> Enum.map(&resolve_structs(&1, caller.aliases))
    |> Enum.flat_map(&param_checks(&1, desc))

    resolved_retval_type = resolve_structs(retval_type, caller.aliases)

    finalized_block = block
    |> inject_param_checks(parameter_checks)
    |> inject_retval_check(fn_name, resolved_retval_type)

    quote do
      Kernel.unquote(macro)(unquote(header), unquote(finalized_block))
    end
  end

  defp resolve_structs({@t, meta, [variable, struct_ast]}, aliases) do
    resolved_struct_ast = resolve_structs(struct_ast, aliases)
    {@t, meta, [variable, resolved_struct_ast]}
  end
  defp resolve_structs({:%, meta, [{:__aliases__, _, [struct_alias]}, struct_content]}, aliases) do
    module = aliases
    |> Enum.flat_map(fn
      {context_alias, context_module} ->
        if (context_alias |> Module.split |> List.last) == Atom.to_string(struct_alias) do
          [context_module]
        else
          []
        end
    end)
    |> case do
      [] -> Module.concat(:Elixir, struct_alias)
      [module] -> module
    end
    {:%, meta, [module, struct_content]}
  end
  defp resolve_structs(other, _), do: other

  @spec naked_params(Macro.t) :: Macro.t
  defp naked_params({@t, _, [varinfo, _typeinfo]}), do: varinfo
  defp naked_params(varinfo), do: varinfo

  defp param_checks({@t, _, [_variable, {type, _, _}]}, _) when type in @noops, do: []
  defp param_checks({@t, meta, [variable, {:as_boolean, _, [spec]}]}, desc) do
    param_checks({@t, meta, [variable, spec]}, desc)
  end
  defp param_checks({@t, meta, [variable, {:|, _, [spec1, spec2]}]}, desc) do
    checks1 = param_checks({@t, meta, [variable, spec1]}, desc)
    checks2 = param_checks({@t, meta, [variable, spec2]}, desc)

    cond do
      checks1 == [] -> []
      checks2 == [] -> []
      true ->
        [check1] = checks1
        [check2] = checks2
        [quote do
          try do
            unquote(check1)
          rescue
            _ -> unquote(check2)
          end
        end]
    end
  end
  defp param_checks({@t, _, [variable, typespec]}, desc) do
    die = quote do
      raise FunctionClauseError,
        module: unquote(desc.module),
        function: unquote(desc.function),
        arity: unquote(desc.arity)
      inspect var!(result) # never called, used to suppress warnings
    end
    [Typespec.to_case(typespec, variable, die)]
  end
  defp param_checks(_, _), do: []

  defp inject_param_checks([do: {:__block__, meta, terms}], checks) do
    [do: {:__block__, meta, checks ++ terms}]
  end
  defp inject_param_checks([do: term], checks) do
    [do: {:__block__, [], checks ++ [term]}]
  end

  defp inject_retval_check(block, _fn_name, nil), do: block
  defp inject_retval_check(block, _fn_name, {noop, _, _}) when noop in @noops, do: block
  defp inject_retval_check(block, fn_name, {:as_boolean, _, [spec]}) do
    inject_retval_check(block, fn_name, spec)
  end
  defp inject_retval_check([do: inner_block], fn_name, check = {:|, _, _}) do
    typestr = ""
    die = quote do
      result_text = inspect(var!(result))
      raise RuntimeError, message: "function #{unquote(fn_name)} should return #{unquote typestr}, got: #{result_text}"
    end
    checks = retval_check(quote do var!(retval) end, fn_name, check, die)
    block = quote do
      var!(retval) = unquote(inner_block)
      unquote(checks)
    end
    [do: block]
  end
  defp inject_retval_check([do: inner_block], fn_name, typedata) do
    typestr = Typespec.to_string(typedata)
    die = quote do
      result_text = inspect(var!(result))
      raise RuntimeError, message: "function #{unquote(fn_name)} should return #{unquote typestr}, got: #{result_text}"
    end
    [do: Typespec.to_case(typedata, inner_block, die)]
  end

  def retval_check(variable, fn_name, {:|, _, [spec1, spec2]}, die) do
    case1 = retval_check(variable, fn_name, spec1, die)
    case2 = retval_check(variable, fn_name, spec2, die)

    quote do
      try do
        unquote(case1)
      rescue
        _ ->
          unquote(case2)
      end
    end
  end
  def retval_check(variable, fn_name, spec, die) do
    Typespec.to_case(spec, variable, die)
  end

end
