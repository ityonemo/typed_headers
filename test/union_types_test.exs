defmodule TypedHeadersTest.UnionTypesTest do
  use ExUnit.Case, async: true
  use TypedHeaders

  def union_header(value :: integer | binary) do
    value
  end
  def union_retval(value) :: integer | binary do
    value
  end

  describe "union types work" do
    test "in the header" do
      assert 47 == union_header(47)
      assert "foo" == union_header("foo")
      assert_raise FunctionClauseError, fn ->
        union_header(:foo)
      end
    end
    test "in the retval" do
      assert 47 == union_retval(47)
      assert "foo" == union_retval("foo")
      assert_raise RuntimeError, fn ->
        union_retval(:foo)
      end
    end
  end

  def multi_union_header(value :: integer | binary | atom) do
    value
  end
  def multi_union_retval(value) :: integer | binary | atom do
    value
  end

  describe "multi-union types work" do
    test "in the header" do
      assert 47 == multi_union_header(47)
      assert "foo" == multi_union_header("foo")
      assert :foo == multi_union_header(:foo)
      assert_raise FunctionClauseError, fn ->
        multi_union_header([])
      end
    end
    test "in the retval" do
      assert 47 == multi_union_retval(47)
      assert "foo" == multi_union_retval("foo")
      assert :foo == multi_union_retval(:foo)
      assert_raise RuntimeError, fn ->
        multi_union_retval([])
      end
    end
  end

end
