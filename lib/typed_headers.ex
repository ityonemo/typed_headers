defmodule TypedHeaders do
  defmacro __using__(_opts) do
    quote do
      import Kernel, except: [def: 2, defp: 2]
      import TypedHeaders.Redef, only: [def: 2, defp: 2]
    end
  end
end
