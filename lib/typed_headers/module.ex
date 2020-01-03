defmodule TypedHeaders.Module do

  def types, do: ~w[module mfa node]a

  def pre_checks({:module, _, _}, variable) do
    [quote do
      function_exported?(unquote(variable), :module_info, 0) ||
        raise FunctionClauseError
    end]
  end
  def pre_checks({:mfa, _, _}, variable) do
    [quote do
      {m, f, a} = unquote(variable)
      function_exported?(m, f, length(a)) ||
        raise FunctionClauseError
    end]
  end
  def pre_checks({:node, _, _}, variable) do
    [quote do
      unquote(variable)
      |> Atom.to_string
      |> String.split("@")
      |> case do
        [a, b] ->
          (:erlang.size(a) > 0) || raise FunctionClauseError
          (:erlang.size(b) > 0) || raise FunctionClauseError
        _ -> raise FunctionClauseError
      end
    end]
  end

  def deep_checks({:module, _, _}, variable, die) do
    [quote do
      function_exported?(unquote(variable), :module_info, 0) ||
        raise unquote(die)
    end]
  end
  def deep_checks({:mfa, _, _}, variable, die) do
    [quote do
      {m, f, a} = unquote(variable)
      function_exported?(m, f, length(a)) ||
        raise unquote(die)
    end]
  end
  def deep_checks({:node, _, _}, variable, die) do
    [quote do
      unquote(variable)
      |> Atom.to_string
      |> String.split("@")
      |> case do
        [a, b] ->
          (:erlang.size(a) > 0) || unquote(die)
          (:erlang.size(b) > 0) || unquote(die)
        _ -> unquote(die)
      end
    end]
  end
  def deep_checks(_, _, _), do: []
end
