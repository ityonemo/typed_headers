defmodule TypedHeadersTest do
  use ExUnit.Case

  defmodule BasicTypes do
    use TypedHeaders

    def int_identity(value :: integer) :: integer do
      value
    end

  end

  test "integer headers" do
    assert 47 == BasicTypes.int_identity(47)
    assert_raise FunctionClauseError, fn ->
      BasicTypes.int_identity("not_an_integer")
    end
  end
end
