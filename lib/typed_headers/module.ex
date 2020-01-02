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

  def post_checks({:module, _, _}, fn_name, _type, variable) do
    [quote do
      function_exported?(unquote(variable), :module_info, 0) ||
        raise RuntimeError, message: "function #{unquote(fn_name)} expects to return a module, #{inspect unquote(variable)} is not available"
    end]
  end
  def post_checks({:mfa, _, _}, fn_name, _type, variable) do
    [quote do
      {m, f, a} = unquote(variable)
      function_exported?(m, f, length(a)) ||
        raise RuntimeError, message: "function #{unquote(fn_name)} expects to return an mfa, module #{m} does not have a function #{f} of arity #{length(a)}"
    end]
  end
  def post_checks({:node, _, _}, fn_name, _type, variable) do
    die = quote do
      raise RuntimeError, message: "function #{unquote(fn_name)} expects to return an node, atom #{unquote variable} doesnt' look like a node"
    end

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
end
