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

end
