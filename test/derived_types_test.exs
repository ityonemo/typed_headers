defmodule TypedHeaderTest.DerivedTypesTest do
  use ExUnit.Case, async: true

  use TypedHeaders

  # header and retval testing for derived simple types
  # term, arity, byte, char, fun, timeout

  def term_header(value :: term) do
    value
  end

  def term_retval(value) :: term do
    value
  end

  describe "for term builtin" do
    test "header is a no-op" do
      assert 47 == term_header(47)
      assert :foo == term_header(:foo)
    end
    test "retval is a no-op" do
      assert 47 == term_retval(47)
      assert :foo == term_retval(:foo)
    end
  end

  def arity_header(value :: arity) do
    value
  end

  def arity_retval(value) :: arity do
    value
  end

  describe "for arity builtin" do
    test "header is checkable" do
      assert 47 == arity_header(47)
      assert_raise FunctionClauseError, fn ->
        arity_header(-1)
      end
      assert_raise FunctionClauseError, fn ->
        arity_header(256)
      end
      assert_raise FunctionClauseError, fn ->
        arity_header(:foo)
      end
    end
    test "retval is checkable" do
      assert 47 == arity_retval(47)
      assert_raise RuntimeError, fn ->
        arity_retval(-1)
      end
      assert_raise RuntimeError, fn ->
        arity_retval(256)
      end
      assert_raise RuntimeError, fn ->
        arity_retval(:foo)
      end
    end
  end

  def byte_header(value :: byte) do
    value
  end

  def byte_retval(value) :: byte do
    value
  end

  describe "for byte builtin" do
    test "header is checkable" do
      assert 47 == byte_header(47)
      assert_raise FunctionClauseError, fn ->
        byte_header(-1)
      end
      assert_raise FunctionClauseError, fn ->
        byte_header(256)
      end
      assert_raise FunctionClauseError, fn ->
        byte_header(:foo)
      end
    end
    test "retval is checkable" do
      assert 47 == byte_retval(47)
      assert_raise RuntimeError, fn ->
        byte_retval(-1)
      end
      assert_raise RuntimeError, fn ->
        byte_retval(256)
      end
      assert_raise RuntimeError, fn ->
        byte_retval(:foo)
      end
    end
  end

  def char_header(value :: char) do
    value
  end

  def char_retval(value) :: char do
    value
  end

  describe "for char builtin" do
    test "header is checkable" do
      assert 47 == char_header(47)
      assert 0x10FFF == char_header(0x10FFF)
      assert_raise FunctionClauseError, fn ->
        char_header(-1)
      end
      assert_raise FunctionClauseError, fn ->
        char_header(0x110000)
      end
      assert_raise FunctionClauseError, fn ->
        char_header(:foo)
      end
    end
    test "retval is checkable" do
      assert 47 == char_retval(47)
      assert 0x10FFF == char_retval(0x10FFF)
      assert_raise RuntimeError, fn ->
        char_retval(-1)
      end
      assert_raise RuntimeError, fn ->
        char_retval(0x110000)
      end
      assert_raise RuntimeError, fn ->
        char_retval(:foo)
      end
    end
  end

  def fun_header(value:: fun) do
    value
  end

  def fun_retval(value) :: fun do
    value
  end

  describe "for fun builtin" do
    test "header is checkable" do
      assert (&IO.puts/1) == fun_header(&IO.puts/1)
      func = &fun_header/1
      assert func == fun_header(func)
      assert_raise FunctionClauseError, fn ->
        fun_header(47)
      end
      assert_raise FunctionClauseError, fn ->
        fun_header(:foo)
      end
    end
    test "retval is checkable" do
      assert (&IO.puts/1) == fun_retval(&IO.puts/1)
      func = &fun_retval/1
      assert func == fun_retval(func)
      assert_raise RuntimeError, fn ->
        fun_retval(47)
      end
      assert_raise RuntimeError, fn ->
        fun_retval(:foo)
      end
    end
  end

  def timeout_header(value :: timeout) do
    value
  end

  def timeout_retval(value) :: timeout do
    value
  end

  describe "for timeout builtin" do
    test "header is checkable" do
      assert 47 == timeout_header(47)
      assert :infinity == timeout_header(:infinity)
      assert_raise FunctionClauseError, fn ->
        timeout_header(-1)
      end
      assert_raise FunctionClauseError, fn ->
        timeout_header(:foo)
      end
    end
    test "retval is checkable" do
      assert 47 == timeout_retval(47)
      assert :infinity == timeout_retval(:infinity)
      assert_raise RuntimeError, fn ->
        timeout_retval(-1)
      end
      assert_raise RuntimeError, fn ->
        timeout_retval(:foo)
      end
    end
  end
end
