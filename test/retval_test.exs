defmodule TypedHeadersTest.RetvalTest do
  use ExUnit.Case, async: true

  defmodule BasicTypes do
    use TypedHeaders

    def int_guarded(value) :: integer, do: value

    def float_guarded(value) :: float, do: value

    def number_guarded(value) :: number, do: value

    def boolean_guarded(value) :: boolean, do: value

    def atom_guarded(value) :: atom, do: value

    def pid_guarded(value) :: pid, do: value

    def reference_guarded(value) :: reference, do: value

    def tuple_guarded(value) :: tuple, do: value

    def list_guarded(value) :: list, do: value

    def map_guarded(value) :: map, do: value

    def struct_guarded(value) :: struct, do: value
  end

  test "guarded integer" do
    assert 47 == BasicTypes.int_guarded(47)
    assert_raise RuntimeError, fn ->
      BasicTypes.int_guarded("not_an_integer")
    end
  end

  test "guarded float" do
    assert 47.0 == BasicTypes.float_guarded(47.0)
    assert_raise RuntimeError, fn ->
      BasicTypes.float_guarded("not_a_float")
    end
  end

  test "guarded number" do
    assert 47.0 == BasicTypes.number_guarded(47.0)
    assert 47 == BasicTypes.number_guarded(47)
    assert_raise RuntimeError, fn ->
      BasicTypes.number_guarded("not_a_number")
    end
  end

  test "guarded boolean" do
    assert false == BasicTypes.boolean_guarded(false)
    assert true == BasicTypes.boolean_guarded(true)
    assert_raise RuntimeError, fn ->
      BasicTypes.boolean_guarded("not_a_boolean")
    end
  end

  test "guarded atom" do
    assert :foo == BasicTypes.atom_guarded(:foo)
    assert_raise RuntimeError, fn ->
      BasicTypes.atom_guarded("not_a_atom")
    end
  end

  test "guarded pid" do
    assert self() == BasicTypes.pid_guarded(self())
    assert_raise RuntimeError, fn ->
      BasicTypes.pid_guarded("not_a_pid")
    end
  end

  test "guarded reference" do
    ref = make_ref()
    assert ref == BasicTypes.reference_guarded(ref)
    assert_raise RuntimeError, fn ->
      BasicTypes.reference_guarded("not_a_reference")
    end
  end

  test "guarded tuple" do
    assert {1, 2} == BasicTypes.tuple_guarded({1, 2})
    assert_raise RuntimeError, fn ->
      BasicTypes.tuple_guarded("not_a_tuple")
    end
  end

  test "guarded list" do
    assert [1, 2] == BasicTypes.list_guarded([1, 2])
    assert_raise RuntimeError, fn ->
      BasicTypes.list_guarded("not_a_list")
    end
  end

  test "guarded map" do
    assert %{} == BasicTypes.map_guarded(%{})
    assert_raise RuntimeError, fn ->
      BasicTypes.map_guarded("not_a_map")
    end
  end

  test "guarded struct" do
    alias TypedHeadersTest.EmptyStruct

    assert %EmptyStruct{} == BasicTypes.struct_guarded(%EmptyStruct{})
    assert_raise RuntimeError, fn ->
      BasicTypes.struct_guarded(%{not: :amap})
    end
  end
end
