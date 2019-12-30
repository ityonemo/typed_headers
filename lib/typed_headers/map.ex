defmodule TypedHeaders.Map do

  def descriptor_to_guard([], variable) do
    quote do
      unquote(variable) == %{}
    end
  end

end
