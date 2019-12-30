defmodule TypedHeadersTest.KeywordTest do
  use ExUnit.Case, async: true
  use TypedHeaders

  def keyword_literal_header(value :: [foo: integer, bar: atom]) do
    value
  end
  def keyword_literal_retval(value) :: [foo: integer, bar: atom] do
    value
  end

  describe "keyword literal typechecking works" do
    test "in the header" do
      assert [foo: 47, bar: :baz] == keyword_literal_header([foo: 47, bar: :baz])
      assert [bar: :baz, foo: 47] == keyword_literal_header([bar: :baz, foo: 47])
      assert [foo: 47, bar: :baz, quux: nil] == keyword_literal_header([foo: 47, bar: :baz, quux: nil])

      assert_raise FunctionClauseError, fn ->
        keyword_literal_header(foo: 47, quux: nil)
      end
      assert_raise FunctionClauseError, fn ->
        keyword_literal_header(bar: :baz, quux: nil)
      end
      assert_raise FunctionClauseError, fn ->
        keyword_literal_header(foo: 47, bar: "baz")
      end
      assert_raise FunctionClauseError, fn ->
        keyword_literal_header(:foo)
      end
    end
    test "in the retval" do
      assert [foo: 47, bar: :baz] == keyword_literal_retval([foo: 47, bar: :baz])
      assert [bar: :baz, foo: 47] == keyword_literal_retval([bar: :baz, foo: 47])
      assert [foo: 47, bar: :baz, quux: nil] == keyword_literal_retval([foo: 47, bar: :baz, quux: nil])

      assert_raise RuntimeError, fn ->
        keyword_literal_retval(foo: 47, quux: nil)
      end
      assert_raise RuntimeError, fn ->
        keyword_literal_retval(bar: :baz, quux: nil)
      end
      assert_raise RuntimeError, fn ->
        keyword_literal_retval(foo: 47, bar: "baz")
      end
      assert_raise RuntimeError, fn ->
        keyword_literal_retval(:foo)
      end
    end
  end

  def keyword_header(value :: keyword) do
    value
  end
  def keyword_retval(value) :: keyword do
    value
  end

  describe "keyword typechecking works" do
    test "in the header" do
      assert [foo: 47, bar: :baz] == keyword_header([foo: 47, bar: :baz])

      assert_raise FunctionClauseError, fn ->
        keyword_header(:foo)
      end
      assert_raise FunctionClauseError, fn ->
        keyword_header([:foo, :bar])
      end
      assert_raise FunctionClauseError, fn ->
        keyword_header([:foo, bar: :baz])
      end
      assert_raise FunctionClauseError, fn ->
        keyword_header([{:foo, :bar}, {"baz", "quux"}])
      end
    end
    test "in the retval" do
      assert [foo: 47, bar: :baz] == keyword_retval([foo: 47, bar: :baz])

      assert_raise RuntimeError, fn ->
        keyword_retval(:foo)
      end
      assert_raise RuntimeError, fn ->
        keyword_retval([:foo, :bar])
      end
      assert_raise RuntimeError, fn ->
        keyword_retval([:foo, bar: :baz])
      end
      assert_raise RuntimeError, fn ->
        keyword_retval([{:foo, :bar}, {"baz", "quux"}])
      end
    end
  end

  def keyword_1_header(value :: keyword(integer)) do
    value
  end
  def keyword_1_retval(value) :: keyword(integer) do
    value
  end

  describe "keyword/1 typechecking works" do
    test "in the header" do
      assert [foo: 47, bar: 42] == keyword_1_header([foo: 47, bar: 42])

      assert_raise FunctionClauseError, fn ->
        keyword_1_header(:foo)
      end
      assert_raise FunctionClauseError, fn ->
        keyword_1_header([:foo, :bar])
      end
      assert_raise FunctionClauseError, fn ->
        keyword_1_header([:foo, bar: :baz])
      end
      assert_raise FunctionClauseError, fn ->
        keyword_1_header([{:foo, :bar}, {"baz", "quux"}])
      end
      assert_raise FunctionClauseError, fn ->
        keyword_1_header([foo: :bar])
      end
      assert_raise FunctionClauseError, fn ->
        keyword_1_header([foo: 47, bar: 42, baz: :quux])
      end
    end
    test "in the retval" do
      assert [foo: 47, bar: 42] == keyword_1_retval([foo: 47, bar: 42])

      assert_raise RuntimeError, fn ->
        keyword_1_retval(:foo)
      end
      assert_raise RuntimeError, fn ->
        keyword_1_retval([:foo, :bar])
      end
      assert_raise RuntimeError, fn ->
        keyword_1_retval([:foo, bar: :baz])
      end
      assert_raise RuntimeError, fn ->
        keyword_1_retval([{:foo, :bar}, {"baz", "quux"}])
      end
      assert_raise RuntimeError, fn ->
        keyword_1_retval([foo: :bar])
      end
      assert_raise RuntimeError, fn ->
        keyword_1_retval([foo: 47, bar: 42, baz: :quux])
      end
    end
  end
end
