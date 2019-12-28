defmodule TypedHeaders.List do
  # code generators for checking lists

  def types, do: ~w[list nonempty_list maybe_improper_list nonempty_improper_list nonempty_maybe_improper_list]a

  alias TypedHeaders.Typespec

  defp die(fn_name, type, value, :post_check) do
    quote do
      raise RuntimeError, message: "function #{unquote(fn_name)} expects type #{unquote(type)}, got #{inspect unquote(value)}"
    end
  end
  defp die(_func, :pre_check) do
    quote do
      raise FunctionClauseError
    end
  end

  def pre_checks(t, variable) do
    iter_checks(t, variable, die(:foo, :pre_check))
  end

  def post_checks(t, fn_name, type, variable) do
    iter_checks(t, variable, die(fn_name, type, variable, :post_check))
  end

  ## ITERATIVE CHECKS

  # t:list/1
  def iter_checks({:list, _, [typedata]}, variable, die) do
    main_check = Typespec.to_guard(typedata, quote do var!(head) end)
    term_check = quote do var!(tail) == [] end
    [check(variable, main_check, term_check, die)]
  end
  # t:list/0
  def iter_checks({:list, _, _}, variable, die) do
    [list_check(variable, die)]
  end
  # t:nonempty_list/1
  def iter_checks({:nonempty_list, _, [typedata]}, variable, die) do
    main_check = Typespec.to_guard(typedata, quote do var!(head) end)
    term_check = quote do var!(tail) == [] end
    [check(variable, main_check, term_check, die, nonempty: true)]
  end
  # t:nonempty_list/0
  def iter_checks({:nonempty_list, _, _}, variable, die) do
    main_check = true
    term_check = quote do var!(tail) == [] end
    [check(variable, main_check, term_check, die, nonempty: true)]
  end
  # t:maybe_improper_list/1
  def iter_checks({:maybe_improper_list, meta, [typedata]}, variable, die) do
    iter_checks({:maybe_improper_list, meta, [typedata, typedata]}, variable, die)
  end
  # t:maybe_improper_list/2
  def iter_checks({:maybe_improper_list, _, [main_type, term_type]}, variable, die) do
    main_check = Typespec.to_guard(main_type, quote do var!(head) end)
    term_check = Typespec.to_guard(term_type, quote do var!(tail) end)

    [check(variable, main_check, term_check, die)]
  end
  # t:maybe_improper_list/0... anything goes, no need to check any()
  def iter_checks({:maybe_improper_list, _, _}, _variable, _die), do: []
  # t:nonempty_improper_list/1
  def iter_checks({:nonempty_improper_list, meta, [typedata]}, variable, die) do
    iter_checks({:nonempty_improper_list, meta, [typedata, typedata]}, variable, die)
  end
  # t:nonempty_improper_list/2
  def iter_checks({:nonempty_improper_list, _, [main_type, term_type]}, variable, die) do
    main_check = Typespec.to_guard(main_type, quote do var!(head) end)
    term_check = Typespec.to_guard(term_type, quote do var!(tail) end)

    [check(variable, main_check, term_check, die, nonempty: true, improper: true)]
  end
  # t:nonempty_improper_list/0
  def iter_checks({:nonempty_improper_list, _, _}, variable, die) do
    [__nonempty_check__(variable, die)]
  end
  # t:nonempty_maybe_improper_list/1
  def iter_checks({:nonempty_maybe_improper_list, meta, [main_type]}, variable, die) do
    iter_checks({:nonempty_maybe_improper_list, meta, [main_type, main_type]}, variable, die)
  end
  # t:nonempty_maybe_improper_list/2
  def iter_checks({:nonempty_maybe_improper_list, _, [main_type, term_type]}, variable, die) do
    main_check = Typespec.to_guard(main_type, quote do var!(head) end)
    term_check = Typespec.to_guard(term_type, quote do var!(tail) end)

    [check(variable, main_check, term_check, die, nonempty: true)]
  end
  # t:nonempty_maybe_improper_list/0
  def iter_checks({:nonempty_maybe_improper_list, _, _}, variable, die) do
    [__nonempty_check__(variable, die)]
  end
  def iter_checks(_, _, _), do: []


  def __nonempty_check__(value, die) do
    quote do
      match?([_ | _], unquote(value)) || raise unquote(die)
    end
  end

  def check(value, main_check, term_check, die, opts \\ []) do
    # generates a check if we need the checked value to be nonempty.
    nonempty_check = if opts[:nonempty], do: __nonempty_check__(value, die)

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

      recursion_fn.(recursion_fn, unquote(value))
    end
  end

  def list_check(value, die) do
    quote do
      recursion_fn = fn
        this, [] -> nil
        this, [_ | var!(rest)] when is_list(var!(rest)) ->
          this.(this, var!(rest))
        this, [_ | _] ->
          unquote(die)
      end

      recursion_fn.(recursion_fn, unquote(value))
    end
  end
end
