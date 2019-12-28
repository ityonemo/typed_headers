defmodule TypedHeaders.Bitstring do
  # code generators for checking lists

  def descriptor_to_guard({:"::", _, [_, n]}, variable) when is_integer(n) do
    quote do
      :erlang.bit_size(unquote(variable)) == unquote(n)
    end
  end

  def descriptor_to_guard({:"::", _, [_, {:*, _, [_, n]}]}, variable) when is_integer(n) do
    quote do
      rem(:erlang.bit_size(unquote(variable)), unquote(n)) == 0
    end
  end
end
