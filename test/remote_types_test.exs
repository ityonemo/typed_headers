defmodule TypedHeadersTest.RemoteTypesTest do
  use ExUnit.Case, async: true
  use TypedHeaders

  def remote_header(value :: String.t) do
    value
  end
  def remote_footer(value) :: String.t do
    value
  end

  describe "remote types work" do
    test "in the header" do
      assert "foo" == remote_header("foo")
      assert_raise FunctionClauseError, fn ->
        remote_header(:foo)
      end
    end
    test "in the footer" do
      assert "foo" == remote_footer("foo")
      assert_raise RuntimeError, fn ->
        remote_footer(:foo)
      end
    end
  end

end
