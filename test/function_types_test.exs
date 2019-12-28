defmodule TypedHeadersTest.FunctionTypesTest do
  use ExUnit.Case, async: true
  use TypedHeaders

  #def zeroarity_header(value :: (-> any)) do
  #  value
  #end
  #def zeroarity_retval(value) :: (-> any) do
  #  value
  #end
#
  #def func, do: :ok
#
  #describe "for functions you can filter by arity" do
  #  test "in the header" do
  #    assert is_function(&func/0, 0)
  #    assert (&func/0) == zeroarity_header(&func/0)
  #    assert_raise FunctionClauseError, fn ->
  #      zeroarity_header(:foo)
  #    end
  #    assert_raise FunctionClauseError, fn ->
  #      zeroarity_header(fn _ -> :ok end)
  #    end
  #  end
  #  test "in the retval" do
  #    assert (&func/0) == zeroarity_retval(&func/0)
  #    assert_raise RuntimeError, fn ->
  #      zeroarity_retval(:foo)
  #    end
  #    assert_raise RuntimeError, fn ->
  #      zeroarity_retval(fn _ -> :ok end)
  #    end
  #  end
  #end
end
