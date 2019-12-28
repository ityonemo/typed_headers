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

  def onearity_header(value :: (any -> any)) do
    value
  end
  def onearity_retval(value) :: (any -> any) do
    value
  end

  def twoarity_header(value :: (any, any -> any)) do
    value
  end
  def twoarity_retval(value) :: (any, any -> any) do
    value
  end

  describe "for aritied functions you can filter by arity" do
    test "in the header" do
      func1 = fn _ -> :ok end
      func2 = fn _, _ -> :ok end

      assert (func1) == onearity_header(func1)
      assert (func2) == twoarity_header(func2)

      assert_raise FunctionClauseError, fn ->
        onearity_header(func2)
      end
      assert_raise FunctionClauseError, fn ->
        twoarity_header(func1)
      end
    end
    test "in the retval" do
      func1 = fn _ -> :ok end
      func2 = fn _, _ -> :ok end

      assert (func1) == onearity_retval(func1)
      assert (func2) == twoarity_retval(func2)

      assert_raise RuntimeError, fn ->
        onearity_retval(func2)
      end
      assert_raise RuntimeError, fn ->
        twoarity_retval(func1)
      end
    end
  end

  def anyarity_header(value :: (... -> any)) do
    value
  end
  def anyarity_retval(value) :: (... -> any) do
    value
  end

  describe "anyarity functions are detectable" do
    test "in the header" do
      func1 = fn _ -> :ok end
      func2 = fn _, _ -> :ok end

      assert (func1) == anyarity_retval(func1)
      assert (func2) == anyarity_retval(func2)
    end
    test "in the retval" do
      func1 = fn _ -> :ok end
      func2 = fn _, _ -> :ok end

      assert (func1) == anyarity_retval(func1)
      assert (func2) == anyarity_retval(func2)
    end
  end
end
