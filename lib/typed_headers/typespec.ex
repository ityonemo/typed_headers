defmodule TypedHeaders.Typespec do

  alias TypedHeaders.Bitstring
  alias TypedHeaders.List

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
    map:       :is_map,
    function:  :is_function,
    port:      :is_port,
    binary:    :is_binary,
    bitstring: :is_bitstring,
    # derived types
    fun:       :is_function,
    module:    :is_atom,
    node:      :is_atom
  }
  @builtins Map.keys(@typefn)
  @full_context [context: Elixir, import: Kernel]

  @list_types List.types

  @literal_brackets [:<<>>, :{}]

  def to_guard({type, _, _}, variable) when type in @builtins do
    typefn(type, variable)
  end
  def to_guard({:neg_integer, _, _}, variable) do
    and_fn(typefn(:integer, variable), {:<, @full_context, [variable, 0]})
  end
  def to_guard({:non_neg_integer, _, _}, variable) do
    and_fn(typefn(:integer, variable), {:>=, @full_context, [variable, 0]})
  end
  def to_guard({:pos_integer, _, _}, variable) do
    and_fn(typefn(:integer, variable), {:>, @full_context, [variable, 0]})
  end
  def to_guard([{:->, _, [[{:..., _, _}], _]}], variable) do
    typefn(:function, variable)
  end
  def to_guard([{:->, _, args}], variable) do
    function(args, variable)
  end
  def to_guard({:->, _, [[{:..., _, _}], _]}, variable) do
    typefn(:function, variable)
  end
  def to_guard({:->, _, args}, variable) do
    function(args, variable)
  end
  def to_guard([{:..., _, _}], variable) do
    typefn(:list, variable)
  end
  def to_guard([_ | _], variable) do
    typefn(:list, variable)
  end
  def to_guard({:<<>>, _, spec}, variable) when length(spec) > 0 do
    Bitstring.descriptor_to_guard(spec, variable)
  end
  def to_guard({:%{}, _, spec}, variable) do
    TypedHeaders.Map.descriptor_to_guard(spec, variable)
  end
  def to_guard({:%, _, [module, {:%{}, _, []}]}, variable) do
    and_fn(
      typefn(:map, variable),
      quote do
        :erlang.map_get(:__struct__, unquote(variable)) == unquote(module)
      end)
  end
  def to_guard({:%, _, [module, {:%{}, _, spec}]}, variable) do
    and_fn(
      and_fn(
        typefn(:map, variable),
        quote do
          :erlang.map_get(:__struct__, unquote(variable)) == unquote(module)
        end),
      TypedHeaders.Map.descriptor_to_guard(spec, variable))
  end
  def to_guard({:struct, _, _}, variable) do
    and_fn(
      typefn(:map, variable),
      quote do
        is_atom(:erlang.map_get(:__struct__, unquote(variable)))
      end)
  end
  def to_guard(literal, variable) when is_integer(literal) or is_atom(literal) or (literal == []) do
    {:===, @full_context, [variable, literal]}
  end
  def to_guard(literal = {operator, _, _}, variable) when operator in @literal_brackets do
    {:===, @full_context, [variable, literal]}
  end
  def to_guard({:.., _, [a, b]}, variable) when is_integer(a) and is_integer(b) and (a <= b) do
    range(a, b, variable)
  end
  # TODO: make a to_guard checker here.
  def to_guard({byte_or_arity, _, _}, variable) when byte_or_arity in [:byte, :arity] do
    range(0, 255, variable)
  end
  def to_guard({:char, _, _}, variable) do
    range(0, 0x10FFF, variable)
  end
  def to_guard({:timeout, _, _}, variable) do
    or_fn(
      and_fn(
        typefn(:integer, variable),
        {:>=, @full_context, [variable, 0]}),
      {:===, @full_context, [variable, :infinity]})
  end
  def to_guard({list_type, _, _}, variable) when list_type in @list_types do
    typefn(:list, variable)
  end
  def to_guard({:mfa, _, _}, variable) do
    and_fn(
      and_fn(
        and_fn(
          typefn(:tuple, variable),
          {:==, @full_context, [{:tuple_size, @full_context, [variable]}, 3]}),
        and_fn(
          typefn(:atom, {:elem, @full_context, [variable, 0]}),
          typefn(:atom, {:elem, @full_context, [variable, 1]}))),
      typefn(:list, {:elem, @full_context, [variable, 2]}))
  end
  def to_guard({:identifier, _, _}, variable) do
    or_fn(
      or_fn(
        typefn(:pid, variable),
        typefn(:port, variable)),
      typefn(:reference, variable))
  end

  def to_string([]), do: "[]"
  def to_string([{:..., _, _}]), do: "[...]"
  def to_string([spec, {:..., _, _}]), do: "[#{__MODULE__.to_string(spec)}...]"
  def to_string(spec = [{atom, _} | _]) when is_atom(atom), do: inspect(spec)
  def to_string([spec]), do: "[#{__MODULE__.to_string(spec)}]"
  def to_string({:<<>>, _, []}), do: "<<>>"
  def to_string({:{}, _, []}), do: "{}"
  def to_string({:.., _, [a, b]}), do: "#{a}..#{b}"
  def to_string(atom) when is_atom(atom), do: ":#{atom}"
  def to_string(int) when is_integer(int), do: "#{int}"
  def to_string({typefn, _, _}), do: "#{typefn}"

  @type lambda :: {:fn, meta::list, block::list(Macro.t)}

  @spec to_lambda(Macro.t, Macro.t) :: lambda
  def to_lambda(typespec, die) do
    variable = quote do var!(result) end
    guard = when_result(typespec, variable)
    deep_check = to_deep_check(typespec, variable, die)
    quote do
      fn
        unquote(guard) ->
          unquote_splicing(deep_check)
        _ -> unquote(die)
      end
    end
  end

  def when_result(typedata, variable) do
    {:when, [], [variable, to_guard(typedata, variable)]}
  end

  @modules [TypedHeaders.List, TypedHeaders.Module, TypedHeaders.Map]

  def to_deep_check(typedata, variable, die) do
    Enum.flat_map(@modules, fn mod ->
      mod.deep_checks(typedata, variable, die)
    end)
  end

  @module_types TypedHeaders.Module.types
  def deep_checks(spec = {module_type, _, _}, variable, die)
      when module_type in @module_types do
    TypedHeaders.Module.deep_checks(spec, variable, die)
  end
  def deep_checks(spec = {:%{}, _, _}, variable, die) do
    TypedHeaders.Map.deep_checks(spec, variable, die)
  end
  def deep_checks(_, _, _), do: []

  def typefn(type, variable), do: {@typefn[type], @full_context, [variable]}

  def and_fn(a, b), do: {:and, @full_context, [a, b]}
  def or_fn(a, b), do:  {:or,  @full_context, [a, b]}

  def range(a, b, variable) do
    and_fn(typefn(:integer, variable),
      and_fn(
        {:>=, @full_context, [variable, a]},
        {:<=, @full_context, [variable, b]}))
  end

  def function([args, _ret], variable) do
    {:is_function, @full_context, [variable, length(args)]}
  end
end
