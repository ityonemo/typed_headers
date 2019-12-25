defmodule TypedHeadersTest.LiteralTypesTest do

  use ExUnit.Case, async: true

  use TypedHeaders

  def integer_literal(value :: 47) do
    value
  end

  def integer_retval(value) :: 47 do
    value
  end

  test "integer_literal" do
    assert 47 == integer_literal(47)
    assert_raise FunctionClauseError, fn ->
      integer_literal(47.0)
    end
    assert_raise FunctionClauseError, fn ->
      integer_literal(0)
    end
    assert_raise FunctionClauseError, fn ->
      integer_literal(:foo)
    end

    assert 47 == integer_retval(47)
    assert_raise RuntimeError, fn ->
      integer_retval(47.0)
    end
    assert_raise RuntimeError, fn ->
      integer_retval(0)
    end
    assert_raise RuntimeError, fn ->
      integer_retval(:foo)
    end
  end

  def integer_range(value :: 42..47) do
    value
  end

  def range_retval(value) :: 42..47 do
    value
  end

  test "integer_range" do
    assert 47 == integer_range(47)
    assert 42 == integer_range(42)
    assert 43 == integer_range(43)

    assert_raise FunctionClauseError, fn ->
      integer_range(43.0)
    end
    assert_raise FunctionClauseError, fn ->
      integer_range(41)
    end
    assert_raise FunctionClauseError, fn ->
      integer_range(48)
    end
    assert_raise FunctionClauseError, fn ->
      integer_range(:foo)
    end

    assert 47 == range_retval(47)
    assert 42 == range_retval(42)
    assert 43 == range_retval(43)

    assert_raise RuntimeError, fn ->
      range_retval(43.0)
    end
    assert_raise RuntimeError, fn ->
      range_retval(41)
    end
    assert_raise RuntimeError, fn ->
      range_retval(48)
    end
    assert_raise RuntimeError, fn ->
      range_retval(:foo)
    end
  end

  def atom_literal(value :: :foo) do
    value
  end

  def atom_retval(value) :: :foo do
    value
  end

  test "atom_literal" do
    assert :foo == atom_literal(:foo)
    assert_raise FunctionClauseError, fn ->
      atom_literal("foo")
    end

    assert :foo == atom_retval(:foo)
    assert_raise RuntimeError, fn ->
      atom_retval("foo")
    end
  end

  def emptystring_literal(value :: <<>>) do
    value
  end

  def emptystring_retval(value) :: <<>> do
    value
  end

  test "emptystring_literal" do
    assert "" == emptystring_literal("")
    assert_raise FunctionClauseError, fn ->
      emptystring_literal("foo")
    end
    assert_raise FunctionClauseError, fn ->
      emptystring_literal(:foo)
    end

    assert "" == emptystring_retval("")
    assert_raise RuntimeError, fn ->
      emptystring_retval("foo")
    end
    assert_raise FunctionClauseError, fn ->
      emptystring_literal(:foo)
    end
  end

  def emptylist_literal(value :: []) do
    value
  end

  def emptylist_retval(value) :: [] do
    value
  end

  test "emptylist_literal" do
    assert [] == emptylist_literal([])
    assert_raise FunctionClauseError, fn ->
      emptylist_literal([:foo])
    end
    assert_raise FunctionClauseError, fn ->
      emptylist_literal(:foo)
    end

    assert [] == emptylist_retval([])
    assert_raise RuntimeError, fn ->
      emptylist_retval([:foo])
    end
    assert_raise FunctionClauseError, fn ->
      emptylist_literal(:foo)
    end
  end

  def emptytuple_literal(value :: {}) do
    value
  end

  def emptytuple_retval(value) :: {} do
    value
  end

  test "emptytuple_literal" do
    assert {} == emptytuple_literal({})
    assert_raise FunctionClauseError, fn ->
      emptytuple_literal({:foo})
    end
    assert_raise FunctionClauseError, fn ->
      emptytuple_literal(:foo)
    end

    assert {} == emptytuple_retval({})
    assert_raise RuntimeError, fn ->
      emptytuple_retval({:foo})
    end
    assert_raise FunctionClauseError, fn ->
      emptytuple_literal(:foo)
    end
  end
end
