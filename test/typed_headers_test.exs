defmodule TypedHeadersTest do
  use ExUnit.Case, async: true

  defmodule BasicTypes do
    use TypedHeaders

    def int_identity(value :: integer) :: integer do
      value
    end

    def float_identity(value :: float) :: float do
      value
    end

    def number_identity(value :: number) :: number do
      value
    end

    def boolean_identity(value :: boolean) :: boolean do
      value
    end

    def atom_identity(value :: atom) :: atom do
      value
    end

    def pid_identity(value :: pid) :: pid do
      value
    end

    def reference_identity(value :: reference) :: reference do
      value
    end

    def tuple_identity(value :: tuple) :: tuple do
      value
    end

    def list_identity(value :: list) :: list do
      value
    end

    def map_identity(value :: map) :: map do
      value
    end

  end

  test "integer headers" do
    assert 47 == BasicTypes.int_identity(47)
    assert_raise FunctionClauseError, fn ->
      BasicTypes.int_identity("not_an_integer")
    end
  end

  test "float headers" do
    assert 47.0 == BasicTypes.float_identity(47.0)
    assert_raise FunctionClauseError, fn ->
      BasicTypes.float_identity(47)
    end
  end

  test "number headers" do
    assert 47 == BasicTypes.number_identity(47)
    assert 47.0 == BasicTypes.number_identity(47.0)
    assert_raise FunctionClauseError, fn ->
      BasicTypes.number_identity("not a number")
    end
  end

  test "boolean headers" do
    assert true == BasicTypes.boolean_identity(true)
    assert false == BasicTypes.boolean_identity(false)
    assert_raise FunctionClauseError, fn ->
      BasicTypes.boolean_identity("not a bool")
    end
  end

  test "atom headers" do
    assert :foo == BasicTypes.atom_identity(:foo)
    assert_raise FunctionClauseError, fn ->
      BasicTypes.atom_identity("not a atom")
    end
  end

  test "pid headers" do
    assert self() == BasicTypes.pid_identity(self())
    assert_raise FunctionClauseError, fn ->
      BasicTypes.pid_identity("not a pid")
    end
  end

  test "reference headers" do
    ref = make_ref()
    assert ref == BasicTypes.reference_identity(ref)
    assert_raise FunctionClauseError, fn ->
      BasicTypes.reference_identity("not a reference")
    end
  end

  ######################################################3######################
  ## collections

  test "tuple headers" do
    assert {:ok, "foo"} == BasicTypes.tuple_identity({:ok, "foo"})
    assert_raise FunctionClauseError, fn ->
      BasicTypes.tuple_identity("not a tuple")
    end
  end

  test "list headers" do
    assert [1, 2] == BasicTypes.list_identity([1, 2])
    assert_raise FunctionClauseError, fn ->
      BasicTypes.list_identity("not a list")
    end
  end

  test "map headers" do
    assert %{} == BasicTypes.map_identity(%{})
    assert_raise FunctionClauseError, fn ->
      BasicTypes.map_identity("not a map")
    end
  end

end
