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
  def to_guard({:iodata, _, _}, variable) do
    or_fn(
      typefn(:list, variable),
      typefn(:binary, variable))
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
  def to_guard(_, _), do: nil

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
  def to_string({:., _, [{:__aliases__, _, [mod]}, type]}), do: "#{mod}.#{type}"
  def to_string({typefn, _, _}), do: "#{inspect typefn}"

  @type case_ast :: [{:case, list, [Macro.t]}] | []

  @spec to_case(Macro.t, Macro.t) :: case_ast
  def to_case(typespec, input) do
    variable = quote do var!(result) end
    guard = when_result(typespec, variable)
    cond do
      guard ->
        deep_check = to_deep_check(typespec, variable)
        quote do
          case unquote(input) do
            unquote(guard) ->
              unquote_splicing(deep_check)
            _ -> false
          end
        end
      match?({_, _, _}, typespec) ->
        {spec, _, params} = typespec
        params = params || []
        quote do
          __type_check__(unquote(spec), unquote(params), unquote(input))
        end
      true -> quote do end
    end
  end

  def when_result(typedata, variable) do
    guard = to_guard(typedata, variable)
    if guard, do: {:when, [], [variable, guard]}
  end

  @modules [TypedHeaders.List, TypedHeaders.Module, TypedHeaders.Map]

  def to_deep_check(typedata, variable) do
    @modules
    |> Enum.flat_map(fn mod ->
      mod.deep_checks(typedata, variable)
    end)
    |> case do
      [] -> [true]
      list -> list
    end
  end

  @module_types TypedHeaders.Module.types
  def deep_checks(spec = {module_type, _, _}, variable)
      when module_type in @module_types do
    TypedHeaders.Module.deep_checks(spec, variable)
  end
  def deep_checks(spec = {:%{}, _, _}, variable) do
    TypedHeaders.Map.deep_checks(spec, variable)
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

  def from_module_type(t = {module, _, _}) do
    module
    |> Code.Typespec.fetch_types
    |> fetch_from_list(t)
  end

  defp fetch_from_list({:ok, typelist}, {module, typename, args}) do
    typelist
    |> Enum.find(&match?({:type, {^typename, _, _}}, &1))
    |> case do
      {:type, {^typename, mod_spec, a}} when length(a) == length(args) ->
        from_module_type(mod_spec, module)
      _ ->
        raise "unidentified module type structure found"
    end
  end
  defp fetch_from_list(_, {module, typename, args}) do
    raise "t:#{module}.#{typename}/#{length args} not found"
  end

  defp from_module_type({:type, _, :tuple, lst}, module) do
    {:{}, [], Enum.map(lst, &from_module_type(&1, module))}
  end
  defp from_module_type({:type, _, :range, [{:integer, _, a}, {:integer, _, b}]}, _module) do
    {:.., [], [a, b]}
  end
  defp from_module_type({:type, _, :map, fields}, module) do
    {:%{}, [], Enum.map(fields, &translate_map_types(&1, module))}
  end
  defp from_module_type({:type, meta, :union, lst}, module) do
    [lst_front, lst_back] = Enum.chunk_every(lst, div(length(lst), 2))
    typ1 = case lst_front do
      [one_type] -> from_module_type(one_type, module)
      many_types -> from_module_type({:type, meta, :union, many_types}, module)
    end
    typ2 = case lst_back do
      [one_type] -> from_module_type(one_type, module)
      many_types -> from_module_type({:type, meta, :union, many_types}, module)
    end
    {:|, [], [typ1, typ2]}
  end
  defp from_module_type({:type, _, type, args}, module) do
    {type, [], Enum.map(args, &from_module_type(&1, module))}
  end
  defp from_module_type({:user_type, _, type, args}, module) do
    from_module_type({module, type, args})
  end
  defp from_module_type({:remote_type, _, [{:atom, _, module}, {:atom, _, type}, args]}, _module) do
    from_module_type({module, type, args})
  end
  defp from_module_type({:integer, _, value}, _module), do: value
  defp from_module_type({:atom, _, value}, _module), do: value
  defp from_module_type(_, _), do: nil

  defp translate_map_types({:type, _, :map_field_exact, [key, value]}, module) do
    {{:required, [], [from_module_type(key, module)]}, from_module_type(value, module)}
  end
  defp translate_map_types({:type, _, :map_field_assoc, [key, value]}, module) do
    {{:optional, [], [from_module_type(key, module)]}, from_module_type(value, module)}
  end
end
