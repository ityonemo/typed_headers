defmodule TypedHeadersTest do
  use ExUnit.Case, async: true

  defmodule BasicTypes do
    use TypedHeaders

    #
    # see: https://hexdocs.pm/elixir/typespecs.html
    #

    def any_header(value :: any) do
      value
    end

    def int_header(value :: integer) do
      value
    end

    def float_header(value :: float) do
      value
    end

    def number_header(value :: number) do
      value
    end

    def boolean_header(value :: boolean) do
      value
    end

    def atom_header(value :: atom) do
      value
    end

    def pid_header(value :: pid) do
      value
    end

    def reference_header(value :: reference) do
      value
    end

    def tuple_header(value :: tuple) do
      value
    end

    def list_header(value :: list) do
      value
    end

    def map_header(value :: map) do
      value
    end

    def function_header(value :: function) do
      value
    end

    def port_header(value :: port) do
      value
    end

    def binary_header(value :: binary) do
      value
    end

    def bitstring_header(value :: bitstring) do
      value
    end

  end

  test "any headers" do
    assert 47 = BasicTypes.any_header(47)
    assert "47" = BasicTypes.any_header("47")
  end

  test "integer headers" do
    assert 47 == BasicTypes.int_header(47)
    assert_raise FunctionClauseError, fn ->
      BasicTypes.int_header("not_an_integer")
    end
  end

  test "float headers" do
    assert 47.0 == BasicTypes.float_header(47.0)
    assert_raise FunctionClauseError, fn ->
      BasicTypes.float_header(47)
    end
  end

  test "number headers" do
    assert 47 == BasicTypes.number_header(47)
    assert 47.0 == BasicTypes.number_header(47.0)
    assert_raise FunctionClauseError, fn ->
      BasicTypes.number_header("not a number")
    end
  end

  test "boolean headers" do
    assert true == BasicTypes.boolean_header(true)
    assert false == BasicTypes.boolean_header(false)
    assert_raise FunctionClauseError, fn ->
      BasicTypes.boolean_header("not a bool")
    end
  end

  test "atom headers" do
    assert :foo == BasicTypes.atom_header(:foo)
    assert_raise FunctionClauseError, fn ->
      BasicTypes.atom_header("not a atom")
    end
  end

  test "pid headers" do
    assert self() == BasicTypes.pid_header(self())
    assert_raise FunctionClauseError, fn ->
      BasicTypes.pid_header("not a pid")
    end
  end

  test "reference headers" do
    ref = make_ref()
    assert ref == BasicTypes.reference_header(ref)
    assert_raise FunctionClauseError, fn ->
      BasicTypes.reference_header("not a reference")
    end
  end

  test "function headers" do
    assert (&IO.puts/1) == BasicTypes.function_header(&IO.puts/1)
    assert_raise FunctionClauseError, fn ->
      BasicTypes.function_header("not a function")
    end
  end

  test "port headers" do
    {:ok, port} = :gen_udp.open(0)
    assert port == BasicTypes.port_header(port)
    assert_raise FunctionClauseError, fn ->
      BasicTypes.port_header("not a port")
    end
  end

  ######################################################3######################
  ## collections

  test "tuple headers" do
    assert {:ok, "foo"} == BasicTypes.tuple_header({:ok, "foo"})
    assert_raise FunctionClauseError, fn ->
      BasicTypes.tuple_header("not a tuple")
    end
  end

  test "list headers" do
    assert [1, 2] == BasicTypes.list_header([1, 2])
    assert_raise FunctionClauseError, fn ->
      BasicTypes.list_header("not a list")
    end
  end

  test "map headers" do
    assert %{} == BasicTypes.map_header(%{})
    assert_raise FunctionClauseError, fn ->
      BasicTypes.map_header("not a map")
    end
  end

  test "binary headers" do
    assert "foo" == BasicTypes.binary_header("foo")
    assert_raise FunctionClauseError, fn ->
      BasicTypes.binary_header(:not_a_binary)
    end
  end

  test "bitstring headers" do
    assert <<10::7>> == BasicTypes.bitstring_header(<<10::7>>)
    assert "foo" == BasicTypes.bitstring_header("foo")
    assert_raise FunctionClauseError, fn ->
      BasicTypes.bitstring_header(:not_a_bitsring)
    end
  end

#  test "struct headers" do
#    alias TypedHeadersTest.EmptyStruct
#
#    assert %EmptyStruct{} == BasicTypes.struct_header(%EmptyStruct{})
#    assert_raise FunctionClauseError, fn ->
#      BasicTypes.struct_header(%{not: :astruct})
#    end
#    assert_raise FunctionClauseError, fn ->
#      BasicTypes.struct_header(%{__struct__: NotAModule})
#    end
#  end

end
