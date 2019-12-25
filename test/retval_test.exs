defmodule TypedHeadersTest.RetvalTest do
  use ExUnit.Case, async: true

  defmodule BasicTypes do
    use TypedHeaders

    def int_retval(value) :: integer, do: value

    def float_retval(value) :: float, do: value

    def number_retval(value) :: number, do: value

    def boolean_retval(value) :: boolean, do: value

    def atom_retval(value) :: atom, do: value

    def pid_retval(value) :: pid, do: value

    def reference_retval(value) :: reference, do: value

    def tuple_retval(value) :: tuple, do: value

    def list_retval(value) :: list, do: value

    def map_retval(value) :: map, do: value

    def function_retval(value) :: function, do: value

    def port_retval(value) :: port, do: value

    def binary_retval(value) :: binary, do: value

    def bitstring_retval(value) :: bitstring, do: value
  end

  test "retval integer" do
    assert 47 == BasicTypes.int_retval(47)
    assert_raise RuntimeError, fn ->
      BasicTypes.int_retval("not_an_integer")
    end
  end

  test "retval float" do
    assert 47.0 == BasicTypes.float_retval(47.0)
    assert_raise RuntimeError, fn ->
      BasicTypes.float_retval("not_a_float")
    end
  end

  test "retval number" do
    assert 47.0 == BasicTypes.number_retval(47.0)
    assert 47 == BasicTypes.number_retval(47)
    assert_raise RuntimeError, fn ->
      BasicTypes.number_retval("not_a_number")
    end
  end

  test "retval boolean" do
    assert false == BasicTypes.boolean_retval(false)
    assert true == BasicTypes.boolean_retval(true)
    assert_raise RuntimeError, fn ->
      BasicTypes.boolean_retval("not_a_boolean")
    end
  end

  test "retval atom" do
    assert :foo == BasicTypes.atom_retval(:foo)
    assert_raise RuntimeError, fn ->
      BasicTypes.atom_retval("not_a_atom")
    end
  end

  test "retval pid" do
    assert self() == BasicTypes.pid_retval(self())
    assert_raise RuntimeError, fn ->
      BasicTypes.pid_retval("not_a_pid")
    end
  end

  test "retval reference" do
    ref = make_ref()
    assert ref == BasicTypes.reference_retval(ref)
    assert_raise RuntimeError, fn ->
      BasicTypes.reference_retval("not_a_reference")
    end
  end

  test "retval tuple" do
    assert {1, 2} == BasicTypes.tuple_retval({1, 2})
    assert_raise RuntimeError, fn ->
      BasicTypes.tuple_retval("not_a_tuple")
    end
  end

  test "retval list" do
    assert [1, 2] == BasicTypes.list_retval([1, 2])
    assert_raise RuntimeError, fn ->
      BasicTypes.list_retval("not_a_list")
    end
  end

  test "retval map" do
    assert %{} == BasicTypes.map_retval(%{})
    assert_raise RuntimeError, fn ->
      BasicTypes.map_retval("not_a_map")
    end
  end

  test "retval functions" do
    assert (&IO.puts/1) == BasicTypes.function_retval(&IO.puts/1)
    assert_raise RuntimeError, fn ->
      BasicTypes.function_retval("not a function")
    end
  end

  test "retval ports" do
    {:ok, port} = :gen_udp.open(0)
    assert port == BasicTypes.port_retval(port)
    assert_raise RuntimeError, fn ->
      BasicTypes.port_retval("not a port")
    end
  end

  test "retval binary" do
    assert "foo" == BasicTypes.binary_retval("foo")
    assert_raise RuntimeError, fn ->
      BasicTypes.binary_retval(:not_a_binary)
    end
  end

  test "retval bitstring" do
    assert <<10::7>> == BasicTypes.bitstring_retval(<<10::7>>)
    assert "foo" == BasicTypes.bitstring_retval("foo")
    assert_raise RuntimeError, fn ->
      BasicTypes.bitstring_retval(:not_a_bitstring)
    end
  end
end
