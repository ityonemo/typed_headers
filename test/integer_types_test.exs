defmodule TypedHeadersTest.IntegerTypesTest do

  use ExUnit.Case, async: true

  use TypedHeaders

  def neg_integer_identity(value :: neg_integer) do
    value
  end

  def neg_integer_retval(value) :: neg_integer do
    value
  end

  def non_neg_integer_identity(value :: non_neg_integer) do
    value
  end

  def non_neg_integer_retval(value) :: non_neg_integer do
    value
  end

  def pos_integer_identity(value :: pos_integer) do
    value
  end

  def pos_integer_retval(value) :: pos_integer do
    value
  end

  test "neg_integer" do
    assert -1 == neg_integer_identity(-1)
    assert_raise FunctionClauseError, fn ->
      neg_integer_identity(-1.0)
    end
    assert_raise FunctionClauseError, fn ->
      neg_integer_identity(0)
    end
    assert_raise FunctionClauseError, fn ->
      neg_integer_identity(1)
    end

    assert -1 == neg_integer_retval(-1)
    assert_raise RuntimeError, fn ->
      neg_integer_retval(-1.0)
    end
    assert_raise RuntimeError, fn ->
      neg_integer_retval(0)
    end
    assert_raise RuntimeError, fn ->
      neg_integer_retval(1)
    end
  end

  test "non_neg_integer" do
    assert 1 == non_neg_integer_identity(1)
    assert_raise FunctionClauseError, fn ->
      non_neg_integer_identity(1.0)
    end
    assert_raise FunctionClauseError, fn ->
      non_neg_integer_identity(-1)
    end

    assert 1 == non_neg_integer_retval(1)
    assert_raise RuntimeError, fn ->
      non_neg_integer_retval(1.0)
    end
    assert_raise RuntimeError, fn ->
      non_neg_integer_retval(-1)
    end
  end

  test "pos_integer" do
    assert 1 == pos_integer_identity(1)
    assert_raise FunctionClauseError, fn ->
      pos_integer_identity(1.0)
    end
    assert_raise FunctionClauseError, fn ->
      pos_integer_identity(0)
    end
    assert_raise FunctionClauseError, fn ->
      pos_integer_identity(-1)
    end

    assert 1 == pos_integer_retval(1)
    assert_raise RuntimeError, fn ->
      pos_integer_retval(1.0)
    end
    assert_raise RuntimeError, fn ->
      pos_integer_retval(0)
    end
    assert_raise RuntimeError, fn ->
      pos_integer_retval(-1)
    end
  end
end
