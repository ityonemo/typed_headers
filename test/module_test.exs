defmodule TypedHeadersTest.ModuleTest do
  use ExUnit.Case, async: true
  use TypedHeaders

  def module_header(value :: module) do
    value
  end
  def module_retval(value) :: module do
    value
  end

  describe "module typechecking works" do
    test "in the header" do
      assert List == module_header(List)
      assert_raise FunctionClauseError, fn ->
        module_header("List")
      end
      assert_raise FunctionClauseError, fn ->
        module_header(FooBar)
      end
    end

    test "in the retval" do
      assert List == module_retval(List)
      assert_raise RuntimeError, fn ->
        module_retval("List")
      end
      assert_raise RuntimeError, fn ->
        module_retval(FooBar)
      end
    end
  end

  def mfa_header(value :: mfa) do
    value
  end
  def mfa_retval(value) :: mfa do
    value
  end

  describe "mfa typechecking works" do
    test "in the header" do
      assert {List, :first, [[:a]]} == mfa_header({List, :first, [[:a]]})
      assert_raise FunctionClauseError, fn ->
        mfa_header("List.first/1")
      end
      assert_raise FunctionClauseError, fn ->
        mfa_header({List, :first, [[:a]], :b})
      end
      assert_raise FunctionClauseError, fn ->
        mfa_header({"List", :first, [[:a]]})
      end
      assert_raise FunctionClauseError, fn ->
        mfa_header({List, "first", [[:a]]})
      end
      assert_raise FunctionClauseError, fn ->
        mfa_header({List, "first", :a})
      end
      assert_raise FunctionClauseError, fn ->
        mfa_header({FooBar, :first, [[:a]]})
      end
      assert_raise FunctionClauseError, fn ->
        mfa_header({List, :first, [[:a], :b]})
      end
    end

    test "in the retval" do
      assert {List, :first, [[:a]]} == mfa_retval({List, :first, [[:a]]})
      assert_raise RuntimeError, fn ->
        mfa_retval("List.first/1")
      end
      assert_raise RuntimeError, fn ->
        mfa_retval({List, :first, [[:a]], :b})
      end
      assert_raise RuntimeError, fn ->
        mfa_retval({"List", :first, [[:a]]})
      end
      assert_raise RuntimeError, fn ->
        mfa_retval({List, "first", [[:a]]})
      end
      assert_raise RuntimeError, fn ->
        mfa_retval({List, "first", :a})
      end
      assert_raise RuntimeError, fn ->
        mfa_retval({FooBar, :first, [[:a]]})
      end
      assert_raise RuntimeError, fn ->
        mfa_retval({List, :first, [[:a], :b]})
      end
    end
  end

  def node_header(value :: node) do
    value
  end

  def node_retval(value) :: node do
    value
  end

  describe "node typechecking works" do
    test "in the header" do
      assert Node.self() == node_header(Node.self())
      assert_raise FunctionClauseError, fn ->
        node_header(:foo)
      end
    end

    test "in the retval" do
      assert Node.self() == node_retval(Node.self())
      assert_raise RuntimeError, fn ->
        node_retval(:foo)
      end
    end
  end
end
