defmodule TypedHeaders do
  defmacro __using__(_opts) do
    quote do
      import Kernel, except: [def: 2, defp: 2]
      import TypedHeaders.Redef, only: [def: 2, defp: 2]

      @before_compile TypedHeaders
    end
  end

  defmacro __before_compile__(env) do
    case Module.get_attribute(env.module, :type) do
      [] -> quote do end
      lst ->
        Enum.map(lst, fn {:type, {:"::", _, [{type, _, params}, defn]}, _} ->
          params = params || []
          variable = quote do var!(value) end
          check = TypedHeaders.Typespec.to_case(defn, variable)
          quote do
            def __type_check__(unquote(type), unquote(params), var!(value)) do
              unquote(check)
            end
          end
        end)
    end
  end
end
