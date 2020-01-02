defmodule TypedHeaders.Map do

  alias TypedHeaders.Typespec

  def descriptor_to_guard([], variable) do
    quote do
      unquote(variable) == %{}
    end
  end
  def descriptor_to_guard(list, variable) do
    list
    |> Enum.flat_map(&literal_keys_to_guards(&1, variable))
    |> combine_guard_list
  end

  def literal_keys_to_guards({atom, type}, variable) when is_atom(atom) do
    interior = quote do
      :erlang.map_get(unquote(atom), unquote(variable))
    end
    [Typespec.to_guard(type, interior)]
  end
  def literal_keys_to_guards({{:required, _, [key_type]}, type}, variable) when is_atom(key_type) or is_integer(key_type) do
    interior = quote do
      :erlang.map_get(unquote(key_type), unquote(variable))
    end
    [Typespec.to_guard(type, interior)]
  end
  def literal_keys_to_guards({{:required, _, [{:<<>>, _, []}]}, type}, variable) do
    interior = quote do
      :erlang.map_get("", unquote(variable))
    end
    [Typespec.to_guard(type, interior)]
  end
  def literal_keys_to_guards({{:required, _, [[]]}, type}, variable) do
    interior = quote do
      :erlang.map_get([], unquote(variable))
    end
    [Typespec.to_guard(type, interior)]
  end
  def literal_keys_to_guards({{:required, _, [{:%{}, _, []}]}, type}, variable) do
    interior = quote do
      :erlang.map_get(%{}, unquote(variable))
    end
    [Typespec.to_guard(type, interior)]
  end
  def literal_keys_to_guards({{:required, _, [{:{}, _, []}]}, type}, variable) do
    interior = quote do
      :erlang.map_get({}, unquote(variable))
    end
    [Typespec.to_guard(type, interior)]
  end
  def literal_keys_to_guards(_, variable) do
    [Typespec.to_guard({:map, [], nil}, variable)]
  end

  def combine_guard_list([]) do
    true
  end
  def combine_guard_list([hd | tl]) do
    Typespec.and_fn(hd, combine_guard_list(tl))
  end

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

  @spec pre_checks(Macro.t, Macro.t) :: Macro.t
  def pre_checks(t, variable) do
    deep_checks(t, variable, die(:foo, :pre_check))
  end

  defguard is_literal(type) when is_atom(type) or is_integer(type) or type == []
  defguard is_empty_literal(atom) when atom in [:<<>>, :{}, :%{}]

  def deep_checks({:%{}, _, list}, variable, die) do
    deep_checks(list, variable, die)
  end

  def deep_checks([], _variable, _die), do: []
  def deep_checks([{{:required, _, [key_type]}, _val_type} | rest], variable, die) when is_literal(key_type) do
    deep_checks(rest, variable, die)
    # TODO: do deep checking when necessary
  end
  def deep_checks([{{:required, _, [{atom, _, _}]}, _val_type} | rest], variable, die) when is_empty_literal(atom) do
    deep_checks(rest, variable, die)
    # TODO: do deep checking when necessary
  end
  def deep_checks([{{:required, meta, [key_type]}, val_type} | rest], variable, die) do
    key_match = Typespec.to_guard(key_type, quote do var!(key) end)
    [quote do
      # make sure that at least one key exists matching the typespec.
      unquote(variable)
      |> Map.keys
      |> Enum.any?(fn var!(key) ->
        unquote(key_match)
      end) || unquote(die)
      # TODO: deep checking on the interior type.
    end] ++ deep_checks([{{:optional, meta, [key_type]}, val_type} | rest], variable, die)
  end
  def deep_checks([{{:optional, _, [key_type]}, val_type} | rest], variable, die) do
    key_match = Typespec.to_guard(key_type, quote do var!(key) end)
    val_match = Typespec.to_guard(val_type, quote do var!(val) end)
    [quote do
      # make sure that all keys matching the typespec match the val type.
      unquote(variable)
      |> Enum.filter(fn {var!(key), _} ->
        unquote(key_match)
      end)
      |> Enum.all?(fn {_, var!(val)} ->
        unquote(val_match)
      end) || unquote(die)
    end] ++ deep_checks(rest, variable, die)
  end
  def deep_checks([_ | rest], variable, die), do: deep_checks(rest, variable, die)

end
