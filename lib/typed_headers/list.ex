defmodule TypedHeaders.List do
  # code generators for checking lists

  @types ~w[list nonempty_list maybe_improper_list nonempty_improper_list nonempty_maybe_improper_list
  charlist nonempty_charlist keyword]a

  def types, do: @types

  alias TypedHeaders.Typespec

  @full_context [context: Elixir, import: Kernel]

  ## DEEP CHECKS

  # guard against functions, which have a funny AST.
  def deep_checks([{:->, _, _}], _variable, _die), do: []
  def deep_checks([{:..., _, _}], variable, die) do
    deep_check({:nonempty_list, @full_context, nil}, variable, die)
  end
  def deep_checks([t, {:..., _, _}], variable, die) do
    deep_check({:nonempty_list, @full_context, [t]}, variable, die)
  end
  def deep_checks(spec = [{atom, _} | _], variable, die) when is_atom(atom) do
    deep_check(spec, variable, die)
  end
  def deep_checks(spec = [_], variable, die) do
    deep_check({:list, [], spec}, variable, die)
  end
  def deep_checks(spec = {list_type, _, _}, variable, die)
      when list_type in @types do
    deep_check(spec, variable, die)
  end
  def deep_checks(_, _, _), do: []

  # t:list/1
  def deep_check({:list, _, [typedata]}, variable, die) do
    main_check = Typespec.to_guard(typedata, quote do var!(head) end)
    term_check = quote do var!(tail) == [] end
    [check(variable, main_check, term_check, die)]
  end
  # t:list/0
  def deep_check({:list, _, _}, variable, die) do
    [list_check(variable, die)]
  end
  # t:nonempty_list/1
  def deep_check({:nonempty_list, _, [typedata]}, variable, die) do
    main_check = Typespec.to_guard(typedata, quote do var!(head) end)
    term_check = quote do var!(tail) == [] end
    [check(variable, main_check, term_check, die, nonempty: true)]
  end
  # t:nonempty_list/0
  def deep_check({:nonempty_list, _, _}, variable, die) do
    main_check = true
    term_check = quote do var!(tail) == [] end
    [check(variable, main_check, term_check, die, nonempty: true)]
  end
  # t:maybe_improper_list/1
  def deep_check({:maybe_improper_list, meta, [typedata]}, variable, die) do
    deep_check({:maybe_improper_list, meta, [typedata, typedata]}, variable, die)
  end
  # t:maybe_improper_list/2
  def deep_check({:maybe_improper_list, _, [main_type, term_type]}, variable, die) do
    main_check = Typespec.to_guard(main_type, quote do var!(head) end)
    term_check = Typespec.to_guard(term_type, quote do var!(tail) end)

    [check(variable, main_check, term_check, die)]
  end
  # t:maybe_improper_list/0... anything goes, no need to check any()
  def deep_check({:maybe_improper_list, _, _}, _variable, _die), do: []
  # t:nonempty_improper_list/1
  def deep_check({:nonempty_improper_list, meta, [typedata]}, variable, die) do
    deep_check({:nonempty_improper_list, meta, [typedata, typedata]}, variable, die)
  end
  # t:nonempty_improper_list/2
  def deep_check({:nonempty_improper_list, _, [main_type, term_type]}, variable, die) do
    main_check = Typespec.to_guard(main_type, quote do var!(head) end)
    term_check = Typespec.to_guard(term_type, quote do var!(tail) end)

    [check(variable, main_check, term_check, die, nonempty: true, improper: true)]
  end
  # t:nonempty_improper_list/0
  def deep_check({:nonempty_improper_list, _, _}, variable, die) do
    [__nonempty_check__(variable, die)]
  end
  # t:nonempty_maybe_improper_list/1
  def deep_check({:nonempty_maybe_improper_list, meta, [main_type]}, variable, die) do
    deep_check({:nonempty_maybe_improper_list, meta, [main_type, main_type]}, variable, die)
  end
  # t:nonempty_maybe_improper_list/2
  def deep_check({:nonempty_maybe_improper_list, _, [main_type, term_type]}, variable, die) do
    main_check = Typespec.to_guard(main_type, quote do var!(head) end)
    term_check = Typespec.to_guard(term_type, quote do var!(tail) end)

    [check(variable, main_check, term_check, die, nonempty: true)]
  end
  # t:nonempty_maybe_improper_list/0
  def deep_check({:nonempty_maybe_improper_list, _, _}, variable, die) do
    [__nonempty_check__(variable, die)]
  end
  def deep_check({:charlist, meta, _}, variable, die) do
    deep_check({:list, meta, [{:char, meta, nil}]}, variable, die)
  end
  def deep_check({:nonempty_charlist, meta, _}, variable, die) do
    deep_check({:nonempty_list, meta, [{:char, meta, nil}]}, variable, die)
  end
  def deep_check(kwl = [{atom, _} | _], variable, die) when is_atom(atom) do
    Enum.map(kwl, fn {key, spec} ->
      guard = Typespec.to_guard(spec, quote do var!(value) end)
      quote do
        Keyword.has_key?(unquote(variable), unquote(key)) || unquote(die)
        case unquote(variable)[unquote(key)] do
          var!(value) when unquote(guard) ->
            nil  # TODO: make this a recursive call.
          _ -> unquote(die)
        end
      end
    end)
  end
  # t:keyword/1
  def deep_check({:keyword, _, [spec]}, variable, die) do
    value_guard = Typespec.to_guard(spec, quote do var!(v) end)
    main_check = quote do
      match?({k, var!(v)} when is_atom(k) and unquote(value_guard), var!(head))
    end
    term_check = quote do var!(tail) == [] end
    [check(variable, main_check, term_check, die)]
  end
  # t:keyword/0
  def deep_check({:keyword, _, _}, variable, die) do
    main_check = quote do
      match?({k, _v} when is_atom(k), var!(head))
    end
    term_check = quote do var!(tail) == [] end
    [check(variable, main_check, term_check, die)]
  end
  def deep_check(_, _, _), do: []


  def __nonempty_check__(variable, die) do
    quote do
      match?([_ | _], unquote(variable)) || raise unquote(die)
    end
  end

  def check(variable, main_check, term_check, die, opts \\ []) do
    # generates a check if we need the checked variable to be nonempty.
    nonempty_check = if opts[:nonempty], do: __nonempty_check__(variable, die)

    # generates a check against the final [] if we are
    eol_check = if opts[:improper], do: die

    quote do
      unquote(nonempty_check)

      recursion_fn = fn
        this, [] -> unquote(eol_check)
        this, [var!(head) | var!(rest)] when is_list(var!(rest)) ->
          unquote(main_check) || unquote(die)
          this.(this, var!(rest))
        this, [var!(head) | var!(tail)] ->
          unquote(main_check) || unquote(die)
          unquote(term_check) || unquote(die)
          nil
      end

      recursion_fn.(recursion_fn, unquote(variable))
    end
  end

  def list_check(variable, die) do
    quote do
      recursion_fn = fn
        this, [] -> nil
        this, [_ | var!(rest)] when is_list(var!(rest)) ->
          this.(this, var!(rest))
        this, [_ | _] ->
          unquote(die)
      end

      recursion_fn.(recursion_fn, unquote(variable))
    end
  end
end
