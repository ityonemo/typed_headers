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
    end
  end

  def maybe_improper_list_2_header(value :: maybe_improper_list(integer, atom)) do
    value
  end

  def maybe_improper_list_2_retval(value) :: maybe_improper_list(integer, atom) do
    value
  end

  describe "maybe_improper_list/2 typechecking works" do
    test "in the header" do
      assert [] == maybe_improper_list_2_header([])
      assert [47] == maybe_improper_list_2_header([47])
      assert [47 | :done] == maybe_improper_list_2_header([47 | :done])
      assert [47, 42] == maybe_improper_list_2_retval([47, 42])
      assert_raise FunctionClauseError, fn ->
        maybe_improper_list_2_header(:foo)
      end
      assert_raise FunctionClauseError, fn ->
        maybe_improper_list_2_header([:done | 47])
      end
      assert_raise FunctionClauseError, fn ->
        maybe_improper_list_2_header([47 | 42])
      end
      assert_raise FunctionClauseError, fn ->
        maybe_improper_list_2_header([47, 42, :done])
      end
    end
    test "in the retval" do
      assert [] == maybe_improper_list_2_retval([])
      assert [47] == maybe_improper_list_2_retval([47])
      assert [47 | :done] == maybe_improper_list_2_retval([47 | :done])
      assert [47, 42] == maybe_improper_list_2_retval([47, 42])
      assert_raise RuntimeError, fn ->
        maybe_improper_list_2_retval(:done)
      end
      assert_raise RuntimeError, fn ->
        maybe_improper_list_2_retval([:done | 47])
      end
      assert_raise RuntimeError, fn ->
        maybe_improper_list_2_retval([47 | 42])
      end
      assert_raise RuntimeError, fn ->
        maybe_improper_list_2_retval([47, 42, :done])
      end
    end
  end

  def nonempty_improper_list_header(value :: nonempty_improper_list) do
    value
  end

  def nonempty_improper_list_retval(value) :: nonempty_improper_list do
    value
  end

  describe "nonempty improper list typechecking works" do
    # NB: in practice, it's impossible to check an untyped nonempty_improper_list to be
    # an actual improper list, because the end item [] is technically allowed.
    test "in the header" do
      assert [47] == nonempty_improper_list_header([47])
      assert [47 | 42] == nonempty_improper_list_header([47 | 42])
      assert_raise FunctionClauseError, fn ->
        nonempty_improper_list_header([])
      end
      assert_raise FunctionClauseError, fn ->
        nonempty_improper_list_header(:foo)
      end
    end
    test "in the retval" do
      assert [47] == nonempty_improper_list_retval([47])
      assert [47 | 42] == nonempty_improper_list_retval([47 | 42])
      assert_raise RuntimeError, fn ->
        nonempty_improper_list_retval([])
      end
      assert_raise RuntimeError, fn ->
        nonempty_improper_list_retval(:foo)
      end
    end
  end

  def nonempty_improper_list_1_header(value :: nonempty_improper_list(integer)) do
    value
  end

  def nonempty_improper_list_1_retval(value) :: nonempty_improper_list(integer) do
    value
  end

  describe "nonempty_improper_list/1 typechecking works" do
    # NB: the nonempty_improper_list type definition is a bit strange since it doesn't
    # admit a naked end term as the result.
    test "in the header" do
      assert [47 | 42] == nonempty_improper_list_1_header([47 | 42])
      assert_raise FunctionClauseError, fn ->
        nonempty_improper_list_1_header(:foo)
      end
      assert_raise FunctionClauseError, fn ->
        nonempty_improper_list_1_header([])
      end
      assert_raise FunctionClauseError, fn ->
        assert [47, 42] == nonempty_improper_list_1_header([47, 42])
      end
    end
    test "in the retval" do
      assert [47 | 42] == nonempty_improper_list_1_retval([47 | 42])
      assert_raise RuntimeError, fn ->
        nonempty_improper_list_1_retval([])
      end
      assert_raise RuntimeError, fn ->
        nonempty_improper_list_1_retval(:foo)
      end
      assert_raise RuntimeError, fn ->
        assert [47, 42] == nonempty_improper_list_1_retval([47, 42])
      end
    end
  end

  def nonempty_improper_list_2_header(value :: nonempty_improper_list(integer, atom)) do
    value
  end

  def nonempty_improper_list_2_retval(value) :: nonempty_improper_list(integer, atom) do
    value
  end

  describe "nonempty_improper_list/2 typechecking works" do
    test "in the header" do
      assert [47 | :foo] == nonempty_improper_list_2_header([47 | :foo])
      assert_raise FunctionClauseError, fn ->
        nonempty_improper_list_2_header(:foo)
      end
      assert_raise FunctionClauseError, fn ->
        nonempty_improper_list_2_header([])
      end
      assert_raise FunctionClauseError, fn ->
        nonempty_improper_list_2_header([47, :foo])
      end
    end
    test "in the retval" do
      assert [47 | :foo] == nonempty_improper_list_2_retval([47 | :foo])
      assert_raise RuntimeError, fn ->
        nonempty_improper_list_2_retval([])
      end
      assert_raise RuntimeError, fn ->
        nonempty_improper_list_2_retval(:foo)
      end
      assert_raise RuntimeError, fn ->
        nonempty_improper_list_2_retval([47, :foo])
      end
    end
  end

  def nonempty_maybe_improper_list_header(value :: nonempty_maybe_improper_list) do
    value
  end

  def nonempty_maybe_improper_list_retval(value) :: nonempty_maybe_improper_list do
    value
  end

  describe "nonempty_maybe_improper_list/0 typechecking works" do
    test "in the header" do
      assert [47] == nonempty_maybe_improper_list_header([47])
      assert [47 | :foo] == nonempty_maybe_improper_list_header([47 | :foo])
      assert [47, 42] == nonempty_maybe_improper_list_header([47, 42])
      assert_raise FunctionClauseError, fn ->
        nonempty_maybe_improper_list_header(:foo)
      end
      assert_raise FunctionClauseError, fn ->
        nonempty_maybe_improper_list_header([])
      end
    end
    test "in the retval" do
      assert [47] == nonempty_maybe_improper_list_header([47])
      assert [47 | :foo] == nonempty_maybe_improper_list_retval([47 | :foo])
      assert [47, 42] == nonempty_maybe_improper_list_retval([47, 42])
      assert_raise RuntimeError, fn ->
        nonempty_maybe_improper_list_retval(:foo)
      end
      assert_raise RuntimeError, fn ->
        nonempty_maybe_improper_list_retval([])
      end
    end
  end

  def nonempty_maybe_improper_list_1_header(value :: nonempty_maybe_improper_list(integer)) do
    value
  end

  def nonempty_maybe_improper_list_1_retval(value) :: nonempty_maybe_improper_list(integer) do
    value
  end

  describe "nonempty_maybe_improper_list/1 typechecking works" do
    test "in the header" do
      assert [47] == nonempty_maybe_improper_list_1_header([47])
      assert [47 | 42] == nonempty_maybe_improper_list_1_header([47 | 42])
      assert [47, 42] == nonempty_maybe_improper_list_1_header([47, 42])
      assert_raise FunctionClauseError, fn ->
        nonempty_maybe_improper_list_1_header(:foo)
      end
      assert_raise FunctionClauseError, fn ->
        nonempty_maybe_improper_list_1_header([])
      end
      assert_raise FunctionClauseError, fn ->
        nonempty_maybe_improper_list_1_header([47, :foo])
      end
      assert_raise FunctionClauseError, fn ->
        nonempty_maybe_improper_list_1_header([47 | :foo])
      end
    end
    test "in the retval" do
      assert [47] == nonempty_maybe_improper_list_1_retval([47])
      assert [47 | 42] == nonempty_maybe_improper_list_1_retval([47 | 42])
      assert [47, 42] == nonempty_maybe_improper_list_1_retval([47, 42])
      assert_raise RuntimeError, fn ->
        nonempty_maybe_improper_list_1_retval([])
      end
      assert_raise RuntimeError, fn ->
        nonempty_maybe_improper_list_1_retval(:foo)
      end
      assert_raise RuntimeError, fn ->
        nonempty_maybe_improper_list_1_retval([47, :foo])
      end
      assert_raise RuntimeError, fn ->
        nonempty_maybe_improper_list_1_retval([47 | :foo])
      end
    end
  end

  def nonempty_maybe_improper_list_2_header(value :: nonempty_maybe_improper_list(integer, atom)) do
    value
  end

  def nonempty_maybe_improper_list_2_retval(value) :: nonempty_maybe_improper_list(integer, atom) do
    value
  end

  describe "nonempty_maybe_improper_list/2 typechecking works" do
    test "in the header" do
      assert [47] == nonempty_maybe_improper_list_2_header([47])
      assert [47 | :foo] == nonempty_maybe_improper_list_2_header([47 | :foo])
      assert [47, 42] == nonempty_maybe_improper_list_2_header([47, 42])
      assert_raise FunctionClauseError, fn ->
        nonempty_maybe_improper_list_2_header(:foo)
      end
      assert_raise FunctionClauseError, fn ->
        nonempty_maybe_improper_list_2_header([])
      end
      assert_raise FunctionClauseError, fn ->
        nonempty_maybe_improper_list_2_header([47, :foo])
      end
    end
    test "in the retval" do
      assert [47] == nonempty_maybe_improper_list_2_header([47])
      assert [47 | :foo] == nonempty_maybe_improper_list_2_retval([47 | :foo])
      assert [47, 42] == nonempty_maybe_improper_list_2_retval([47, 42])
      assert_raise RuntimeError, fn ->
        nonempty_maybe_improper_list_2_retval([])
      end
      assert_raise RuntimeError, fn ->
        nonempty_maybe_improper_list_2_retval(:foo)
      end
      assert_raise RuntimeError, fn ->
        nonempty_maybe_improper_list_2_retval([47, :foo])
      end
    end
  end

  def nonempty_list_literal_header(value :: [...]) do
    value
  end

  def nonempty_list_literal_retval(value) :: [...] do
    value
  end

  describe "nonempty list literal typechecking works" do
    test "in the header" do
      assert [47] == nonempty_list_literal_header([47])
      assert [47, 42] == nonempty_list_literal_header([47, 42])
      assert_raise FunctionClauseError, fn ->
        nonempty_list_literal_header([47 | :foo])
      end
      assert_raise FunctionClauseError, fn ->
        nonempty_list_literal_header(:foo)
      end
      assert_raise FunctionClauseError, fn ->
        nonempty_list_literal_header([])
      end
    end
    test "in the retval" do
      assert [47] == nonempty_list_literal_retval([47])
      assert [47, 42] == nonempty_list_literal_retval([47, 42])
      assert_raise RuntimeError, fn ->
        nonempty_list_literal_retval([47 | :foo])
      end
      assert_raise RuntimeError, fn ->
        nonempty_list_literal_retval([])
      end
      assert_raise RuntimeError, fn ->
        nonempty_list_literal_retval(:foo)
      end
    end
  end

  def nonempty_list_literal_1_header(value :: [integer, ...]) do
    value
  end

  def nonempty_list_literal_1_retval(value) :: [integer, ...] do
    value
  end

  describe "nonempty list literal with parameter typechecking works" do
    test "in the header" do
      assert [47] == nonempty_list_literal_1_header([47])
      assert [47, 42] == nonempty_list_literal_1_header([47, 42])
      assert_raise FunctionClauseError, fn ->
        nonempty_list_literal_1_header([47, :foo])
      end
      assert_raise FunctionClauseError, fn ->
        nonempty_list_literal_1_header([47 | :foo])
      end
      assert_raise FunctionClauseError, fn ->
        nonempty_list_literal_1_header(:foo)
      end
      assert_raise FunctionClauseError, fn ->
        nonempty_list_literal_1_header([])
      end
    end
    test "in the retval" do
      assert [47] == nonempty_list_literal_1_retval([47])
      assert [47, 42] == nonempty_list_literal_1_retval([47, 42])
      assert_raise RuntimeError, fn ->
        nonempty_list_literal_1_retval([47, :foo])
      end
      assert_raise RuntimeError, fn ->
        nonempty_list_literal_1_retval([47 | :foo])
      end
      assert_raise RuntimeError, fn ->
        nonempty_list_literal_1_retval([])
      end
      assert_raise RuntimeError, fn ->
        nonempty_list_literal_1_retval(:foo)
      end
    end
  end

  def charlist_header(value :: charlist) do
    value
  end
  def charlist_retval(value) :: charlist do
    value
  end

  describe "charlist typechecking works" do
    test "in the header" do
      assert 'foo' == charlist_header('foo')
      assert '' == charlist_header('')

      assert_raise FunctionClauseError, fn ->
        charlist_header("foo")
      end
      assert_raise FunctionClauseError, fn ->
        charlist_header([?f, ?o, :o])
      end
      assert_raise FunctionClauseError, fn ->
        charlist_header([?f, ?o | ?o])
      end
    end
    test "in the retval" do
      assert 'foo' == charlist_retval('foo')
      assert '' == charlist_retval('')

      assert_raise RuntimeError, fn ->
        charlist_retval("foo")
      end
      assert_raise RuntimeError, fn ->
        charlist_retval([?f, ?o, :o])
      end
      assert_raise RuntimeError, fn ->
        charlist_retval([?f, ?o | ?o])
      end
    end
  end

  def nonempty_charlist_header(value :: nonempty_charlist) do
    value
  end
  def nonempty_charlist_retval(value) :: nonempty_charlist do
    value
  end

  describe "nonempty charlist typechecking works" do
    test "in the header" do
      assert 'foo' == nonempty_charlist_header('foo')

      assert_raise FunctionClauseError, fn ->
        nonempty_charlist_header('')
      end
      assert_raise FunctionClauseError, fn ->
        nonempty_charlist_header("foo")
      end
      assert_raise FunctionClauseError, fn ->
        nonempty_charlist_header([?f, ?o, :o])
      end
      assert_raise FunctionClauseError, fn ->
        nonempty_charlist_header([?f, ?o | ?o])
      end
    end
    test "in the retval" do
      assert 'foo' == nonempty_charlist_retval('foo')

      assert_raise RuntimeError, fn ->
        nonempty_charlist_retval('')
      end
      assert_raise RuntimeError, fn ->
        nonempty_charlist_retval("foo")
      end
      assert_raise RuntimeError, fn ->
        nonempty_charlist_retval([?f, ?o, :o])
      end
      assert_raise RuntimeError, fn ->
        nonempty_charlist_retval([?f, ?o | ?o])
      end
    end
  end

  def iolist_header(value :: iolist) do
    value
  end
  def iolist_retval(value) :: iolist do
    value
  end

  describe "iolist typechecking works" do
    test "in the header" do
      assert 'foo' == iolist_header('foo')
      assert ["foo"] == iolist_header(["foo"])
      assert ["foo", 'bar'] == iolist_header(["foo", 'bar'])
      assert ["foo" | "bar"] == iolist_header(["foo" | "bar"])
      assert ["foo", 'bar' | "baz"] == iolist_header(["foo", 'bar' | "baz"])

      assert_raise FunctionClauseError, fn ->
        iolist_header(:foo)
      end
      assert_raise FunctionClauseError, fn ->
        iolist_header("foo")
      end
      assert_raise FunctionClauseError, fn ->
        iolist_header(["foo", :bar])
      end
      assert_raise FunctionClauseError, fn ->
        iolist_header(["foo", [:bar]])
      end
      assert_raise FunctionClauseError, fn ->
        iolist_header(["foo", 'bar' | :baz])
      end
    end
    test "in the retval" do
      assert 'foo' == iolist_retval('foo')
      assert ["foo"] == iolist_retval(["foo"])
      assert ["foo", 'bar'] == iolist_retval(["foo", 'bar'])
      assert ["foo" | "bar"] == iolist_retval(["foo" | "bar"])
      assert ["foo", 'bar' | "baz"] == iolist_retval(["foo", 'bar' | "baz"])

      assert_raise RuntimeError, fn ->
        iolist_retval(:foo)
      end
      assert_raise RuntimeError, fn ->
        iolist_retval("foo")
      end
      assert_raise RuntimeError, fn ->
        iolist_retval(["foo", :bar])
      end
      assert_raise RuntimeError, fn ->
        iolist_retval(["foo", [:bar]])
      end
      assert_raise RuntimeError, fn ->
        iolist_retval(["foo", 'bar' | :baz])
      end
    end
  end

  def iodata_header(value :: iodata) do
    value
  end
  def iodata_retval(value) :: iodata do
    value
  end

  describe "iodata typechecking works" do
    test "in the header" do
      assert 'foo' == iodata_header('foo')
      assert "foo" == iodata_header("foo")
      assert ["foo"] == iodata_header(["foo"])
      assert ["foo", 'bar'] == iodata_header(["foo", 'bar'])
      assert ["foo" | "bar"] == iodata_header(["foo" | "bar"])
      assert ["foo", 'bar' | "baz"] == iodata_header(["foo", 'bar' | "baz"])

      assert_raise FunctionClauseError, fn ->
        iodata_header(:foo)
      end
      assert_raise FunctionClauseError, fn ->
        iodata_header(["foo", :bar])
      end
      assert_raise FunctionClauseError, fn ->
        iodata_header(["foo", [:bar]])
      end
      assert_raise FunctionClauseError, fn ->
        iodata_header(["foo", 'bar' | :baz])
      end
    end
    test "in the retval" do
      assert 'foo' == iodata_retval('foo')
      assert "foo" == iodata_retval("foo")
      assert ["foo"] == iodata_retval(["foo"])
      assert ["foo", 'bar'] == iodata_retval(["foo", 'bar'])
      assert ["foo" | "bar"] == iodata_retval(["foo" | "bar"])
      assert ["foo", 'bar' | "baz"] == iodata_retval(["foo", 'bar' | "baz"])

      assert_raise RuntimeError, fn ->
        iodata_retval(:foo)
      end
      assert_raise RuntimeError, fn ->
        iodata_retval(["foo", :bar])
      end
      assert_raise RuntimeError, fn ->
        iodata_retval(["foo", [:bar]])
      end
      assert_raise RuntimeError, fn ->
        iodata_retval(["foo", 'bar' | :baz])
      end
    end
  end
end
