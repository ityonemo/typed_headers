defmodule TypedHeaders.Redef do

  @t :"::"
  @noops [:any, :term]

  alias TypedHeaders.Typespec

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

  defp pre_statements({@t, _, [variable, [typedata]]}) do
    inner_variable = quote do var!(inner_val) end
    typecheck = Typespec.to_guard(typedata, inner_variable)
    [quote do
      Enum.each(unquote(variable), fn
        var!(inner_val) when unquote(typecheck) -> :ok
        _ -> raise FunctionClauseError
      end)
    end]
  end
  defp pre_statements({@t, _, [variable, {:list, _, [typedata]}]}) do
    # TODO: DRY THIS UP WITH ABOVE ^^^
    inner_variable = quote do var!(inner_val) end
    typecheck = Typespec.to_guard(typedata, inner_variable)
    [quote do
      Enum.each(unquote(variable), fn
        var!(inner_val) when unquote(typecheck) -> :ok
        _ -> raise FunctionClauseError
      end)
    end]
  end
  defp pre_statements({@t, _, [variable, {:nonempty_list, _, [typedata]}]}) do
    # TODO: DRY THIS UP WITH ABOVE ^^^
    inner_variable = quote do var!(inner_val) end
    typecheck = Typespec.to_guard(typedata, inner_variable)
    [quote do
      Enum.each(unquote(variable), fn
        var!(inner_val) when unquote(typecheck) -> :ok
        _ -> raise FunctionClauseError
      end)
    end]
  end
  defp pre_statements({@t, _, [variable, {:maybe_improper_list, _, [type]}]}) do
    # TODO: DRY THIS UP WITH BELOW VVV
    main_check = Typespec.to_guard(type, quote do var!(head) end)
    term_check = Typespec.to_guard(type, quote do var!(tail) end)
    [quote do
      recursion_fn = fn
        this, [] -> :ok
        this, [var!(head) | var!(rest)] when is_list(var!(rest)) ->
          unquote(main_check) || raise FunctionClauseError
          this.(this, var!(rest))
        this, [var!(head) | var!(tail)] ->
          unquote(main_check) || raise FunctionClauseError
          unquote(term_check) || raise FunctionClauseError
          :ok
      end

      recursion_fn.(recursion_fn, unquote(variable))
    end]
  end
  defp pre_statements({@t, _, [variable, {:maybe_improper_list, _, [main_type, term_type]}]}) do
    # TODO: DRY THIS UP WITH ABOVE ^^^
    main_check = Typespec.to_guard(main_type, quote do var!(head) end)
    term_check = Typespec.to_guard(term_type, quote do var!(tail) end)
    [quote do
      recursion_fn = fn
        this, [] -> :ok
        this, [var!(head) | var!(rest)] when is_list(var!(rest)) ->
          unquote(main_check) || raise FunctionClauseError
          this.(this, var!(rest))
        this, [var!(head) | var!(tail)] ->
          unquote(main_check) || raise FunctionClauseError
          unquote(term_check) || raise FunctionClauseError
          :ok
      end

      recursion_fn.(recursion_fn, unquote(variable))
    end]
  end
  defp pre_statements({@t, _, [variable, {:nonempty_improper_list, _, [type]}]}) do
    # TODO: DRY THIS UP WITH BELOW VVV
    main_check = Typespec.to_guard(type, quote do var!(head) end)
    term_check = Typespec.to_guard(type, quote do var!(tail) end)
    [quote do
      recursion_fn = fn
        this, [var!(head) | var!(rest)] when is_list(var!(rest)) ->
          unquote(main_check) || raise FunctionClauseError
          this.(this, var!(rest))
        this, [var!(head) | var!(tail)] ->
          unquote(main_check) || raise FunctionClauseError
          unquote(term_check) || raise FunctionClauseError
          :ok
      end

      recursion_fn.(recursion_fn, unquote(variable))
    end]
  end
  defp pre_statements({@t, _, [variable, {:nonempty_improper_list, _, [main_type, term_type]}]}) do
    # TODO: DRY THIS UP WITH ABOVE ^^^
    main_check = Typespec.to_guard(main_type, quote do var!(head) end)
    term_check = Typespec.to_guard(term_type, quote do var!(tail) end)
    [quote do
      recursion_fn = fn
        this, [] -> raise FunctionClauseError
        this, [var!(head) | var!(rest)] when is_list(var!(rest)) ->
          unquote(main_check) || raise FunctionClauseError
          this.(this, var!(rest))
        this, [var!(head) | var!(tail)] ->
          unquote(main_check) || raise FunctionClauseError
          unquote(term_check) || raise FunctionClauseError
          :ok
      end

      recursion_fn.(recursion_fn, unquote(variable))
    end]
  end
  defp pre_statements({@t, _, [variable, {:nonempty_improper_list, _, _}]}) do
    [quote do
      match?([_ | _], unquote(variable)) || raise FunctionClauseError
    end]
  end
  defp pre_statements(_), do: []

  defp inject_prestatements([do: {:__block__, meta, terms}], prestatements) do
    [do: {:__block__, meta, prestatements ++ terms}]
  end
  defp inject_prestatements([do: term], prestatements) do
    [do: {:__block__, [], prestatements ++ [term]}]
  end

  defp post_statements([typedata], fn_name, type, value) do
    inner_variable = quote do var!(inner_val) end
    typecheck = Typespec.to_guard(typedata, inner_variable)
    [quote do
      Enum.each(unquote(value), fn
        var!(inner_val) when unquote(typecheck) -> :ok
        _ ->
          show = inspect unquote(value)
          raise RuntimeError, message: "function #{unquote(fn_name)} expects type #{unquote(type)}, got #{show}"
      end)
    end]
  end
  defp post_statements({:list, _, [typedata]}, fn_name, type, value) do
    post_statements([typedata], fn_name, type, value)
  end
  defp post_statements({:nonempty_list, _, [typedata]}, fn_name, type, value) do
    post_statements([typedata], fn_name, type, value)
  end
  defp post_statements({:maybe_improper_list, meta, [typedata]}, fn_name, type, value) do
    post_statements({:maybe_improper_list, meta, [typedata, typedata]}, fn_name, type, value)
  end
  defp post_statements({:maybe_improper_list, _, [main_type, term_type]}, fn_name, type, value) do
    main_check = Typespec.to_guard(main_type, quote do var!(head) end)
    term_check = Typespec.to_guard(term_type, quote do var!(tail) end)
    [quote do
      die = fn ->
        show = inspect unquote(value)
        raise RuntimeError, message: "function #{unquote(fn_name)} expects type #{unquote(type)}, got #{show}"
      end

      recursion_fn = fn
        this, [] -> :ok
        this, [var!(head) | var!(rest)] when is_list(var!(rest)) ->
          unquote(main_check) || die.()
          this.(this, var!(rest))
        this, [var!(head) | var!(tail)] ->
          unquote(main_check) || die.()
          unquote(term_check) || die.()
          :ok
      end

      recursion_fn.(recursion_fn, unquote(value))
    end]
  end
  defp post_statements({:nonempty_improper_list, meta, [typedata]}, fn_name, type, value) do
    post_statements({:nonempty_improper_list, meta, [typedata, typedata]}, fn_name, type, value)
  end
  defp post_statements({:nonempty_improper_list, _, [main_type, term_type]}, fn_name, type, value) do
    main_check = Typespec.to_guard(main_type, quote do var!(head) end)
    term_check = Typespec.to_guard(term_type, quote do var!(tail) end)

    die = quote do
      raise RuntimeError, message: "function #{unquote(fn_name)} expects type #{unquote(type)}, got #{inspect unquote(value)}"
    end

    [quote do
      recursion_fn = fn
        this, [] -> unquote(die)
        this, [var!(head) | var!(rest)] when is_list(var!(rest)) ->
          unquote(main_check) || unquote(die)
          this.(this, var!(rest))
        this, [var!(head) | var!(tail)] ->
          unquote(main_check) || unquote(die)
          unquote(term_check) || unquote(die)
          :ok
      end

      recursion_fn.(recursion_fn, unquote(value))
    end]
  end
  defp post_statements({:nonempty_improper_list, _, _}, fn_name, type, value) do
    [quote do
      match?([_ | _], unquote(value)) || raise RuntimeError, message: "function #{unquote(fn_name)} expects type #{unquote(type)} #{inspect unquote(value)}"
    end]
  end
  defp post_statements(_, _, _, _), do: []

  defp inject_check([do: term], _fn_name, nil), do: [do: term]
  defp inject_check([do: term], _fn_name, {noop, _, _}) when noop in @noops, do: [do: term]
  defp inject_check([do: term], fn_name, typedata) do
    typestr = Typespec.to_string(typedata)
    inject_check(term,
      fn_name,
      typestr,
      post_statements(typedata, fn_name, typestr, quote do var!(result) end),
      when_result(typedata))
  end

  defp inject_check(term, fn_name, type, postcheck, guard) do
    new_directive = quote do
      case unquote(term) do
        unquote(guard) ->
          unquote_splicing(postcheck)
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
