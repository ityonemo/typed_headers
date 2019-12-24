defmodule TypedHeaders.Redef do

  @t :"::"

  defmacro def({@t, _, [{fn_name, meta, params}, _retval_type]}, block) do

    naked_params = Enum.map(params, &naked_params/1)
    [when_1] = Enum.map(params, &when_statements/1)

    header = {:when, [context: Elixir], [{fn_name, meta, naked_params}, when_1]}

    quote do
      Kernel.def(unquote(header), unquote(block))
    end
  end

  defp naked_params({@t, _, [varinfo, _typeinfo]}), do: varinfo

  @typefn %{integer: :is_integer}

  defp when_statements({@t, _, [varinfo, {type, _, _}]}) do
    {@typefn[type], [context: Elixir, import: Kernel], [varinfo]}
  end
end
