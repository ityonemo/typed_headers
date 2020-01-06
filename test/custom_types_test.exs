defmodule TypedHeadersTest.CustomTypesTest do
  use ExUnit.Case, async: true
  use TypedHeaders

  @type foo :: integer

  def custom_header(value :: foo) do
    value
  end
  def custom_footer(value) :: foo do
    value
  end

  describe "custom types work" do
    test "in the header" do
      assert 47 == custom_header(47)
      assert_raise FunctionClauseError, fn ->
        custom_header(:foo)
      end
    end
  end

end
