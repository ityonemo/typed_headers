defmodule TypedHeadersTest.FromModuleTypeTest do
  #
  # tests that TypedHeaders.Typespec.from_module_type/1 works
  #

  use ExUnit.Case, async: true

  alias TypedHeaders.Typespec

  @moduletag :one

  test "basic String.t/0 works" do
    assert {:binary, _, []} = Typespec.from_module_type({String, :t, []})
  end
  test "user_type String.grapheme/0 works" do
    # note that this is recursive.
    assert {:binary, _, []} = Typespec.from_module_type({String, :grapheme, []})
  end
  test "remote Path.t/0 works" do
    assert {:binary, _, []} = Typespec.from_module_type({BasicType, :t, []})
  end
  test "integer type works" do
    assert 47 = Typespec.from_module_type({BasicType, :i, []})
  end
  test "atom type works" do
    assert :foo = Typespec.from_module_type({BasicType, :a, []})
  end
  test "tuple type works" do
    assert {:{}, _, [:foo, :bar]} = Typespec.from_module_type({BasicType, :tup, []})
  end
  test "union type works" do
    assert {:|, _, [{:integer, _, []}, {:binary, _, []}]} =
      Typespec.from_module_type({BasicType, :union, []})
  end
  test "map type works" do
    assert {:%{}, _, [{{:required, _, [:foo]}, {:integer, _, []}}]} =
      Typespec.from_module_type({BasicType, :m, []})
  end
  test "optional map type works" do
    assert {:%{}, _, [{{:optional, _, [:foo]}, {:integer, _, []}}]} =
      Typespec.from_module_type({BasicType, :om, []})
  end
  test "list type works" do
    assert {:list, _, [{:binary, _, []}]} = Typespec.from_module_type({BasicType, :l, []})
  end
end
