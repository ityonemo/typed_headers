defmodule TypedHeadersTest.FunctionTypesTest do
  use ExUnit.Case, async: true
  use TypedHeaders

  def zeroarity_header(value :: (-> any)) do
    value
  end
  def zeroarity_retval(value) :: (-> any) do
    value
  end

  describe "for functions you can filter by arity" do
    test "in the header" do
      func = fn -> :ok end
      assert is_function(func, 0)
      assert (func) == zeroarity_header(func)
      assert_raise FunctionClauseError, fn ->
        zeroarity_header(:foo)
      end
      assert_raise FunctionClauseError, fn ->
        zeroarity_header(fn _ -> :ok end)
      end
    end
    test "in the retval" do
      func = fn -> :ok end
      assert (func) == zeroarity_retval(func)
      assert_raise RuntimeError, fn ->
        zeroarity_retval(:foo)
      end
      assert_raise RuntimeError, fn ->
        zeroarity_retval(fn _ -> :ok end)
      end
    end
  end
end
