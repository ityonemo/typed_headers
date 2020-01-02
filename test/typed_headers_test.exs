defmodule TypedHeadersTest do
  use ExUnit.Case, async: true
    use TypedHeaders

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

  test "any headers" do
    assert 47 = any_header(47)
    assert "47" = any_header("47")
  end

  test "integer headers" do
    assert 47 == int_header(47)
    assert_raise FunctionClauseError, fn ->
      int_header("not_an_integer")
    end
  end

  test "float headers" do
    assert 47.0 == float_header(47.0)
    assert_raise FunctionClauseError, fn ->
      float_header(47)
    end
  end

  test "number headers" do
    assert 47 == number_header(47)
    assert 47.0 == number_header(47.0)
    assert_raise FunctionClauseError, fn ->
      number_header("not a number")
    end
  end

  test "boolean headers" do
    assert true == boolean_header(true)
    assert false == boolean_header(false)
    assert_raise FunctionClauseError, fn ->
      boolean_header("not a bool")
    end
  end

  test "atom headers" do
    assert :foo == atom_header(:foo)
    assert_raise FunctionClauseError, fn ->
      atom_header("not a atom")
    end
  end

  test "pid headers" do
    assert self() == pid_header(self())
    assert_raise FunctionClauseError, fn ->
      pid_header("not a pid")
    end
  end

  test "reference headers" do
    ref = make_ref()
    assert ref == reference_header(ref)
    assert_raise FunctionClauseError, fn ->
      reference_header("not a reference")
    end
  end

  test "function headers" do
    assert (&IO.puts/1) == function_header(&IO.puts/1)
    assert_raise FunctionClauseError, fn ->
      function_header("not a function")
    end
  end

  test "port headers" do
    {:ok, port} = :gen_udp.open(0)
    assert port == port_header(port)
    assert_raise FunctionClauseError, fn ->
      port_header("not a port")
    end
  end

  ######################################################3######################
  ## collections

  test "tuple headers" do
    assert {:ok, "foo"} == tuple_header({:ok, "foo"})
    assert_raise FunctionClauseError, fn ->
      tuple_header("not a tuple")
    end
  end

  test "list headers" do
    assert [1, 2] == list_header([1, 2])
    assert_raise FunctionClauseError, fn ->
      list_header("not a list")
    end
  end

  test "map headers" do
    assert %{} == map_header(%{})
    assert_raise FunctionClauseError, fn ->
      map_header("not a map")
    end
  end

  test "binary headers" do
    assert "foo" == binary_header("foo")
    assert_raise FunctionClauseError, fn ->
      binary_header(:not_a_binary)
    end
  end

  test "bitstring headers" do
    assert <<10::7>> == bitstring_header(<<10::7>>)
    assert "foo" == bitstring_header("foo")
    assert_raise FunctionClauseError, fn ->
      bitstring_header(:not_a_bitsring)
    end
  end

#  test "struct headers" do
#    alias TypedHeadersTest.EmptyStruct
#
#    assert %EmptyStruct{} == struct_header(%EmptyStruct{})
#    assert_raise FunctionClauseError, fn ->
#      struct_header(%{not: :astruct})
#    end
#    assert_raise FunctionClauseError, fn ->
#      struct_header(%{__struct__: NotAModule})
#    end
#  end

end
