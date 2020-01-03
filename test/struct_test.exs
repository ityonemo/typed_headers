defmodule TypedHeadersTest.StructTest do

  use ExUnit.Case, async: true
  use TypedHeaders

  defmodule TestStruct do
    defstruct [:foo]
  end

  defmodule OtherStruct do
    defstruct [:foo]
  end

  def struct_header(value :: %TestStruct{}) do
    value
  end
  def struct_retval(value) :: %TestStruct{} do
    value
  end

  test "struct headers" do
    assert %TestStruct{} == struct_header(%TestStruct{})
    assert_raise FunctionClauseError, fn ->
      struct_header(%{not: :astruct})
    end
    assert_raise FunctionClauseError, fn ->
      struct_header(%OtherStruct{})
    end
    # fake struct, extra value
    assert_raise FunctionClauseError, fn ->
      struct_header(%{__struct__: TestStruct, foo: :bar, baz: :quux})
    end
    # fake struct, deficient value
    assert_raise FunctionClauseError, fn ->
      struct_header(%{__struct__: TestStruct})
    end
  end

  test "struct retvals" do
    assert %TestStruct{} == struct_retval(%TestStruct{})
    assert_raise RuntimeError, fn ->
      struct_retval(%{not: :astruct})
    end
    assert_raise RuntimeError, fn ->
      struct_retval(%OtherStruct{})
    end
    # fake struct, extra value
    assert_raise RuntimeError, fn ->
      struct_retval(%{__struct__: TestStruct, foo: :bar, baz: :quux})
    end
    # fake struct, deficient value
    assert_raise RuntimeError, fn ->
      struct_retval(%{__struct__: TestStruct})
    end
  end

  def typed_struct_header(value :: %TestStruct{foo: integer}) do
    value
  end
  def typed_struct_retval(value) :: %TestStruct{foo: integer} do
    value
  end

  test "typed struct header" do
    assert %TestStruct{foo: 47} == typed_struct_header(%TestStruct{foo: 47})
    assert_raise FunctionClauseError, fn ->
      typed_struct_header(%TestStruct{})
    end
  end

  test "typed struct retval" do
    assert %TestStruct{foo: 47} == typed_struct_retval(%TestStruct{foo: 47})
    assert_raise RuntimeError, fn ->
      typed_struct_retval(%TestStruct{})
    end
  end
end
