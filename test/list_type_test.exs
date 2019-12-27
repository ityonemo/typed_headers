defmodule TypedHeadersTest.ListTypeTest do
  use ExUnit.Case, async: true
  use TypedHeaders

  def list_header(value :: [integer]) do
    value
  end

  def list_retval(value) :: [integer] do
    value
  end

  describe "list typechecking works" do
    test "in the header" do
      assert [] == list_header([])
      assert [47] == list_header([47])
      assert [47, 42] == list_header([47, 42])
      assert_raise FunctionClauseError, fn ->
        list_header(:foo)
      end
      assert_raise FunctionClauseError, fn ->
        list_header([:foo])
      end
      assert_raise FunctionClauseError, fn ->
        list_header([47, :foo])
      end
      # TODO: raise on improper list.
    end
    test "in the retval" do
      assert [] == list_retval([])
      assert [47] == list_retval([47])
      assert [47, 42] == list_retval([47, 42])
      assert_raise RuntimeError, fn ->
        list_retval(:foo)
      end
      assert_raise RuntimeError, fn ->
        list_retval([:foo])
      end
      assert_raise RuntimeError, fn ->
        list_retval([47, :foo])
      end
      # TODO: raise on improper list.
    end
  end

  def proper_list_header(value :: list(integer)) do
    value
  end

  def proper_list_retval(value) :: list(integer) do
    value
  end

  describe "proper list typechecking works" do
    test "in the header" do
      assert [] == proper_list_header([])
      assert [47] == proper_list_header([47])
      assert [47, 42] == proper_list_header([47, 42])
      assert_raise FunctionClauseError, fn ->
        proper_list_header(:foo)
      end
      assert_raise FunctionClauseError, fn ->
        proper_list_header([:foo])
      end
      assert_raise FunctionClauseError, fn ->
        proper_list_header([47, :foo])
      end
      # TODO: raise on improper list.
    end
    test "in the retval" do
      assert [] == proper_list_retval([])
      assert [47] == proper_list_retval([47])
      assert [47, 42] == proper_list_retval([47, 42])
      assert_raise RuntimeError, fn ->
        proper_list_retval(:foo)
      end
      assert_raise RuntimeError, fn ->
        proper_list_retval([:foo])
      end
      assert_raise RuntimeError, fn ->
        proper_list_retval([47, :foo])
      end
      # TODO: raise on improper list.
    end
  end

  def nonempty_list_header(value :: nonempty_list(integer)) do
    value
  end

  def nonempty_list_retval(value) :: nonempty_list(integer) do
    value
  end

  describe "nonempty list typechecking works" do
    test "in the header" do
      assert [47] == nonempty_list_header([47])
      assert [47, 42] == nonempty_list_header([47, 42])
      assert_raise FunctionClauseError, fn ->
        assert [] == nonempty_list_header([])
      end
      assert_raise FunctionClauseError, fn ->
        nonempty_list_header(:foo)
      end
      assert_raise FunctionClauseError, fn ->
        nonempty_list_header([:foo])
      end
      assert_raise FunctionClauseError, fn ->
        nonempty_list_header([47, :foo])
      end
      # TODO: raise on improper list.
    end
    test "in the retval" do
      assert [47] == nonempty_list_retval([47])
      assert [47, 42] == nonempty_list_retval([47, 42])
      assert_raise RuntimeError, fn ->
        assert [] == nonempty_list_retval([])
      end
      assert_raise RuntimeError, fn ->
        nonempty_list_retval(:foo)
      end
      assert_raise RuntimeError, fn ->
        nonempty_list_retval([:foo])
      end
      assert_raise RuntimeError, fn ->
        nonempty_list_retval([47, :foo])
      end
      # TODO: raise on improper list.
    end
  end

  def maybe_improper_list_header(value :: maybe_improper_list) do
    value
  end

  def maybe_improper_list_retval(value) :: maybe_improper_list do
    value
  end

  describe "maybe improper list typechecking works" do
    test "in the header" do
      assert [] == maybe_improper_list_header([])
      assert [47] == maybe_improper_list_header([47])
      assert [47 | 42] == maybe_improper_list_header([47 | 42])
      assert_raise FunctionClauseError, fn ->
        maybe_improper_list_header(:foo)
      end
    end
    test "in the retval" do
      assert [] == maybe_improper_list_retval([])
      assert [47] == maybe_improper_list_retval([47])
      assert [47 | 42] == maybe_improper_list_retval([47 | 42])
      assert_raise RuntimeError, fn ->
        maybe_improper_list_retval(:foo)
      end
      # TODO: raise on improper list.
    end
  end

  def maybe_improper_list_1_header(value :: maybe_improper_list(integer)) do
    value
  end

  def maybe_improper_list_1_retval(value) :: maybe_improper_list(integer) do
    value
  end

  describe "maybe_improper_list/1 typechecking works" do
    test "in the header" do
      assert [] == maybe_improper_list_1_header([])
      assert [47] == maybe_improper_list_1_header([47])
      assert [47 | 42] == maybe_improper_list_1_header([47 | 42])
      assert_raise FunctionClauseError, fn ->
        maybe_improper_list_1_header(:foo)
      end
      assert_raise FunctionClauseError, fn ->
        maybe_improper_list_1_header([:foo | 47])
      end
      assert_raise FunctionClauseError, fn ->
        maybe_improper_list_1_header([47 | :foo])
      end
    end
    test "in the retval" do
      assert [] == maybe_improper_list_1_retval([])
      assert [47] == maybe_improper_list_1_retval([47])
      assert [47 | 42] == maybe_improper_list_1_retval([47 | 42])
      assert_raise RuntimeError, fn ->
        maybe_improper_list_1_retval(:foo)
      end
      assert_raise RuntimeError, fn ->
        maybe_improper_list_1_retval([:foo | 47])
      end
      assert_raise RuntimeError, fn ->
        maybe_improper_list_1_retval([47 | :foo])
      end
      # TODO: raise on improper list.
    end
  end
end
