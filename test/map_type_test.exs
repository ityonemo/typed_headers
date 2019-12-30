defmodule TypedHeadersTest.MapTypeTest do

  use ExUnit.Case, async: true
  use TypedHeaders

  def empty_map_header(value :: %{}) do
    value
  end

  def empty_map_retval(value) :: %{} do
    value
  end

  describe "empty map literal works" do
    test "in the header" do
      assert %{} == empty_map_header(%{})
      assert_raise FunctionClauseError, fn ->
        empty_map_header([])
      end
      assert_raise FunctionClauseError, fn ->
        empty_map_header(%{foo: :bar})
      end
      # TODO: raise on improper list.
    end
    test "in the retval" do
      assert %{} == empty_map_retval(%{})
      assert_raise RuntimeError, fn ->
        empty_map_retval([])
      end
      assert_raise RuntimeError, fn ->
        empty_map_retval(%{foo: :bar})
      end
      # TODO: raise on improper list.
    end
  end

end
