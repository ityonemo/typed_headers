defmodule TypedHeaders.Typespec do

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
  }
  @builtins Map.keys(@typefn)
  @full_context [context: Elixir, import: Kernel]

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
  def to_guard([_], variable) do
    typefn(:list, variable)
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
  def to_guard({:nonempty_list, _, _}, variable) do
    and_fn(typefn(:list, variable), {:is_list, @full_context, [{:tl, @full_context, [variable]}]})
  end
  def to_guard({:maybe_improper_list, _, _}, variable) do
    typefn(:list, variable)
  end
  def to_guard({:nonempty_improper_list, _, _}, variable) do
    typefn(:list, variable)
  end
  def to_guard({:nonempty_maybe_improper_list, _, _}, variable) do
    typefn(:list, variable)
  end

  def to_string([]), do: "[]"
  def to_string([spec]), do: "[#{__MODULE__.to_string(spec)}]"
  def to_string({:<<>>, _, []}), do: "<<>>"
  def to_string({:{}, _, []}), do: "{}"
  def to_string({:.., _, [a, b]}), do: "#{a}..#{b}"
  def to_string(atom) when is_atom(atom), do: ":#{atom}"
  def to_string(int) when is_integer(int), do: "#{int}"
  def to_string({typefn, _, _}), do: "#{typefn}"

  def typefn(type, variable), do: {@typefn[type], @full_context, [variable]}

  def and_fn(a, b), do: {:and, @full_context, [a, b]}
  def or_fn(a, b), do:  {:or,  @full_context, [a, b]}

  def range(a, b, variable) do
    and_fn(typefn(:integer, variable),
      and_fn(
        {:>=, @full_context, [variable, a]},
        {:<=, @full_context, [variable, b]}))
  end
end
