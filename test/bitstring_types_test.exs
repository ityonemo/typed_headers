defmodule TypedHeadersTest.BitstringTypesTest do
  use ExUnit.Case, async: true
  use TypedHeaders

  def bitstring_size_header(value :: <<_::8>>) do
    value
  end
  def bitstring_size_retval(value) :: <<_::8>> do
    value
  end

  describe "for bitstrings you can filter by size" do
    test "in the header" do
      assert <<10>> == bitstring_size_header(<<10>>)
      assert_raise FunctionClauseError, fn ->
        bitstring_size_header(:foo)
      end
      assert_raise FunctionClauseError, fn ->
        bitstring_size_header("ab")
      end
    end
    test "in the retval" do
      assert <<10>> == bitstring_size_retval(<<10>>)
      assert_raise RuntimeError, fn ->
        bitstring_size_retval(:foo)
      end
      assert_raise RuntimeError, fn ->
        bitstring_size_retval("ab")
      end
    end
  end

  def bitstring_unit_header(value :: <<_::_ * 7>>) do
    value
  end
  def bitstring_unit_retval(value) :: <<_::_ * 7>> do
    value
  end

  describe "for bitstrings you can filter by unit" do
    test "in the header" do
      assert <<10::14>> == bitstring_unit_header(<<10::14>>)
      assert <<10::21>> == bitstring_unit_header(<<10::21>>)
      assert_raise FunctionClauseError, fn ->
        bitstring_unit_header(:foo)
      end
      assert_raise FunctionClauseError, fn ->
        bitstring_unit_header("ab")
      end
    end
    test "in the retval" do
      assert <<10::14>> == bitstring_unit_retval(<<10::14>>)
      assert <<10::21>> == bitstring_unit_retval(<<10::21>>)
      assert_raise RuntimeError, fn ->
        bitstring_unit_retval(:foo)
      end
      assert_raise RuntimeError, fn ->
        bitstring_unit_retval("ab")
      end
    end
  end

  def bitstring_duple_header(value :: <<_::3, _::_ * 7>>) do
    value
  end
  def bitstring_duple_retval(value) :: <<_::3, _::_ * 7>> do
    value
  end

  describe "for bitstrings you can filter by size + unit" do
    test "in the header" do
      assert <<10::10>> == bitstring_duple_header(<<10::10>>)
      assert <<10::17>> == bitstring_duple_header(<<10::17>>)
      assert_raise FunctionClauseError, fn ->
        bitstring_duple_header(:foo)
      end
      assert_raise FunctionClauseError, fn ->
        bitstring_duple_header("ab")
      end
    end
    test "in the retval" do
      assert <<10::10>> == bitstring_duple_retval(<<10::10>>)
      assert <<10::17>> == bitstring_duple_retval(<<10::17>>)
      assert_raise RuntimeError, fn ->
        bitstring_duple_retval(:foo)
      end
      assert_raise RuntimeError, fn ->
        bitstring_duple_retval("ab")
      end
    end
  end

end
