defmodule TypedHeaders.List do
  # code generators for checking lists

  @types ~w[list nonempty_list maybe_improper_list nonempty_improper_list nonempty_maybe_improper_list
  charlist nonempty_charlist keyword iolist iodata]a

  def types, do: @types

  alias TypedHeaders.Typespec

  @full_context [context: Elixir, import: Kernel]

  ## DEEP CHECKS

  # guard against functions, which have a funny AST.
  def deep_checks([{:->, _, _}], _variable), do: []
  def deep_checks([{:..., _, _}], variable) do
    deep_check({:nonempty_list, @full_context, nil}, variable)
  end
  def deep_checks([t, {:..., _, _}], variable) do
    deep_check({:nonempty_list, @full_context, [t]}, variable)
  end
  def deep_checks(spec = [{atom, _} | _], variable) when is_atom(atom) do
    deep_check(spec, variable)
  end
  def deep_checks(spec = [_], variable) do
    deep_check({:list, [], spec}, variable)
  end
  def deep_checks(spec = {list_type, _, _}, variable)
      when list_type in @types do
    deep_check(spec, variable)
  end
  def deep_checks(_, _), do: []

  # t:list/1
  def deep_check({:list, _, [typedata]}, variable) do
    main_check = Typespec.to_case(typedata, quote do var!(head) end)
    term_check = quote do var!(tail) == [] end
    [check(variable, main_check, term_check)]
  end
  # t:list/0
  def deep_check({:list, _, _}, variable) do
    [list_check(variable)]
  end
  # t:nonempty_list/1
  def deep_check({:nonempty_list, _, [typedata]}, variable) do
    main_check = Typespec.to_guard(typedata, quote do var!(head) end)
    term_check = quote do var!(tail) == [] end
    [check(variable, main_check, term_check, nonempty: true)]
  end
  # t:nonempty_list/0
  def deep_check({:nonempty_list, _, _}, variable) do
    term_check = quote do var!(tail) == [] end
    [check(variable, nil, term_check, nonempty: true)]
  end
  # t:maybe_improper_list/1
  def deep_check({:maybe_improper_list, meta, [typedata]}, variable) do
    deep_check({:maybe_improper_list, meta, [typedata, typedata]}, variable)
  end
  # t:maybe_improper_list/2
  def deep_check({:maybe_improper_list, _, [main_type, term_type]}, variable) do
    main_check = Typespec.to_guard(main_type, quote do var!(head) end)
    term_check = Typespec.to_guard(term_type, quote do var!(tail) end)

    [check(variable, main_check, term_check)]
  end
  # t:maybe_improper_list/0... anything goes, no need to check any()
  def deep_check({:maybe_improper_list, _, _}, _variable), do: []
  # t:nonempty_improper_list/1
  def deep_check({:nonempty_improper_list, meta, [typedata]}, variable) do
    deep_check({:nonempty_improper_list, meta, [typedata, typedata]}, variable)
  end
  # t:nonempty_improper_list/2
  def deep_check({:nonempty_improper_list, _, [main_type, term_type]}, variable) do
    main_check = Typespec.to_guard(main_type, quote do var!(head) end)
    term_check = Typespec.to_guard(term_type, quote do var!(tail) end)

    [check(variable, main_check, term_check, nonempty: true, improper: true)]
  end
  # t:nonempty_improper_list/0
  def deep_check({:nonempty_improper_list, _, _}, variable) do
    [nonempty_check(variable)]
  end
  # t:nonempty_maybe_improper_list/1
  def deep_check({:nonempty_maybe_improper_list, meta, [main_type]}, variable) do
    deep_check({:nonempty_maybe_improper_list, meta, [main_type, main_type]}, variable)
  end
  # t:nonempty_maybe_improper_list/2
  def deep_check({:nonempty_maybe_improper_list, _, [main_type, term_type]}, variable) do
    main_check = Typespec.to_guard(main_type, quote do var!(head) end)
    term_check = Typespec.to_guard(term_type, quote do var!(tail) end)

    [check(variable, main_check, term_check, nonempty: true)]
  end
  # t:nonempty_maybe_improper_list/0
  def deep_check({:nonempty_maybe_improper_list, _, _}, variable) do
    [nonempty_check(variable)]
  end
  def deep_check({:charlist, meta, _}, variable) do
    deep_check({:list, meta, [{:char, meta, nil}]}, variable)
  end
  def deep_check({:nonempty_charlist, meta, _}, variable) do
    deep_check({:nonempty_list, meta, [{:char, meta, nil}]}, variable)
  end
  def deep_check([first = {key1, _} | rest], variable) when is_atom(key1) do
    init = keyspec_to_check(first, variable)

    [Enum.reduce(rest, init, fn keyspec, acc ->
      this_check = keyspec_to_check(keyspec, variable)
      quote do unquote(acc) && unquote(this_check) end
    end)]
  end
  # t:keyword/1
  def deep_check({:keyword, _, [spec]}, variable) do
    value_guard = Typespec.to_guard(spec, quote do var!(v) end)
    main_check = quote do
      match?({k, var!(v)} when is_atom(k) and unquote(value_guard), var!(head))
    end
    term_check = quote do var!(tail) == [] end
    [check(variable, main_check, term_check)]
  end
  # t:keyword/0
  def deep_check({:keyword, _, _}, variable) do
    main_check = quote do
      match?({k, _v} when is_atom(k), var!(head))
    end
    term_check = quote do var!(tail) == [] end
    [check(variable, main_check, term_check)]
  end
  # t:iolist/0
  def deep_check({io, _, _}, variable) when io in [:iolist, :iodata] do
    [quote do
      recursion_fn = fn
        _this, [] -> true
        this, [a | b] ->
          this.(this, a) && this.(this, b)
        _this, binary when is_binary(binary) -> true
        _this, char when is_integer(char) and 0 <= char and char <= 0x10FFF -> true
        _this, _result -> false
      end
      recursion_fn.(recursion_fn, unquote(variable))
    end]
  end
  def deep_check(_, _), do: []

  def nonempty_check(variable) do
    quote do
      match?([_ | _], unquote(variable))
    end
  end

  def check(variable, main_check, term_check, opts \\ [])
  def check(variable, nil, term_check, opts) do
    # generates a check if we need the checked variable to be nonempty.
    recursive_check = if opts[:nonempty] do
      nec = nonempty_check(variable)
      quote do
        unquote(nec) && recursion_fn.(recursion_fn, unquote(variable))
      end
    else
      quote do
        recursion_fn.(recursion_fn, unquote(variable))
      end
    end

    # generates a check against the final [] if we are
    eol_check = ! opts[:improper]

    quote do
      recursion_fn = fn
        this, [] -> unquote(eol_check)
        this, [_ | var!(rest)] when is_list(var!(rest)) ->
          this.(this, var!(rest))
        this, [_ | var!(tail)] ->
          unquote(term_check)
      end
      unquote(recursive_check)
    end
  end
  def check(variable, main_check, term_check, opts) do
    # generates a check if we need the checked variable to be nonempty.
    recursive_check = if opts[:nonempty] do
      nec = nonempty_check(variable)
      quote do
        unquote(nec) && recursion_fn.(recursion_fn, unquote(variable))
      end
    else
      quote do
        recursion_fn.(recursion_fn, unquote(variable))
      end
    end

    # generates a check against the final [] if we are
    eol_check = ! opts[:improper]

    quote do
      recursion_fn = fn
        this, [] -> unquote(eol_check)
        this, [var!(head) | var!(rest)] when is_list(var!(rest)) ->
          unquote(main_check) && this.(this, var!(rest))
        this, [var!(head) | var!(tail)] ->
          unquote(main_check) && unquote(term_check)
      end
      unquote(recursive_check)
    end
  end

  def list_check(variable) do
    quote do
      recursion_fn = fn
        this, [] -> true
        this, [_ | rest] when is_list(rest) ->
          this.(this, rest)
        this, [_ | _] -> false
      end

      recursion_fn.(recursion_fn, unquote(variable))
    end
  end

  def keyspec_to_check({key, spec}, variable) do
    deep_case = Typespec.to_case(spec, quote do unquote(variable)[unquote(key)] end)
    quote do
      Keyword.has_key?(unquote(variable), unquote(key)) && unquote(deep_case)
    end
  end
end
