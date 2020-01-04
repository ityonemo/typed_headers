defmodule TypedHeaders.Module do

  def types, do: ~w[module mfa node]a

  def deep_checks({:module, _, _}, variable) do
    [quote do
      function_exported?(unquote(variable), :module_info, 0)
    end]
  end
  def deep_checks({:mfa, _, _}, variable) do
    [quote do
      {m, f, a} = unquote(variable)
      function_exported?(m, f, length(a))
    end]
  end
  def deep_checks({:node, _, _}, variable) do
    [quote do
      unquote(variable)
      |> Atom.to_string
      |> String.split("@")
      |> case do
        [a, b] ->
          (:erlang.size(a) > 0) && (:erlang.size(b) > 0)
        _ -> false
      end
    end]
  end
  def deep_checks(_, _), do: []
end
