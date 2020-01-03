defmodule TypedHeadersTest.AsBooleanTest do
  use ExUnit.Case, async: true
  use TypedHeaders

  # this is a silly use of as_boolean:
  def as_boolean_header(value :: as_boolean(integer)) do
    value
  end
  def as_boolean_retval(value) :: as_boolean(integer) do
    value
  end

  describe "as_boolean guard works" do
    test "in the header" do
      assert 47 == as_boolean_header(47)
      assert_raise FunctionClauseError, fn ->
        as_boolean_header(:foo)
      end
    end
    test "in the retval" do
      assert 47 == as_boolean_retval(47)
      assert_raise RuntimeError, fn ->
        as_boolean_retval(:foo)
      end
    end
  end

  def as_boolean_term_header(value :: as_boolean(term)) do
    value
  end
  def as_boolean_term_retval(value) :: as_boolean(term) do
    value
  end

  describe "as_boolean guard works for term" do
    test "in the header" do
      assert 47 == as_boolean_term_header(47)
      assert false == as_boolean_term_header(false)
    end
    test "in the retval" do
      assert 47 == as_boolean_term_retval(47)
      assert false == as_boolean_term_retval(false)
    end
  end
end
