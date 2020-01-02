defmodule TypedHeadersTest.MapTypeTest do

  use ExUnit.Case, async: true
  use TypedHeaders

  def empty_map_header(value :: %{}) do
    value
  end

  def empty_map_retval(value) :: %{} do
    value
  end

  describe "empty map literal works" do
    test "in the header" do
      assert %{} == empty_map_header(%{})
      assert_raise FunctionClauseError, fn ->
        empty_map_header([])
      end
      assert_raise FunctionClauseError, fn ->
        empty_map_header(%{foo: :bar})
      end
      # TODO: raise on improper list.
    end
    test "in the retval" do
      assert %{} == empty_map_retval(%{})
      assert_raise RuntimeError, fn ->
        empty_map_retval([])
      end
      assert_raise RuntimeError, fn ->
        empty_map_retval(%{foo: :bar})
      end
      # TODO: raise on improper list.
    end
  end

  def atom_key_header(value :: %{foo: integer}) do
    value
  end

  def atom_key_retval(value) :: %{foo: integer} do
    value
  end

  describe "atom key literal works" do
    test "in the header" do
      assert %{foo: 47} == atom_key_header(%{foo: 47})
      assert %{foo: 47, bar: :baz} == atom_key_header(%{foo: 47, bar: :baz})
      assert_raise FunctionClauseError, fn ->
        atom_key_header([])
      end
      assert_raise FunctionClauseError, fn ->
        atom_key_header(%{bar: 47})
      end
      assert_raise FunctionClauseError, fn ->
        atom_key_header(%{foo: :bar})
      end
    end
    test "in the retval" do
      assert %{foo: 47} == atom_key_retval(%{foo: 47})
      assert %{foo: 47, bar: :baz} == atom_key_retval(%{foo: 47, bar: :baz})
      assert_raise RuntimeError, fn ->
        atom_key_retval([])
      end
      assert_raise RuntimeError, fn ->
        atom_key_retval(%{bar: 47})
      end
      assert_raise RuntimeError, fn ->
        atom_key_retval(%{foo: :bar})
      end
    end
  end

  def required_atom_key_header(value :: %{required(:foo) => integer}) do
    value
  end
  def required_atom_key_retval(value) :: %{required(:foo) => integer} do
    value
  end

  describe "required atom key literal works" do
    test "in the header" do
      assert %{foo: 47} == required_atom_key_header(%{foo: 47})
      assert %{foo: 47, bar: :baz} == required_atom_key_header(%{foo: 47, bar: :baz})
      assert_raise FunctionClauseError, fn ->
        required_atom_key_header([])
      end
      assert_raise FunctionClauseError, fn ->
        required_atom_key_header(%{bar: 47})
      end
      assert_raise FunctionClauseError, fn ->
        required_atom_key_header(%{foo: :bar})
      end
    end
    test "in the retval" do
      assert %{foo: 47} == required_atom_key_retval(%{foo: 47})
      assert %{foo: 47, bar: :baz} == required_atom_key_retval(%{foo: 47, bar: :baz})
      assert_raise RuntimeError, fn ->
        required_atom_key_retval([])
      end
      assert_raise RuntimeError, fn ->
        required_atom_key_retval(%{bar: 47})
      end
      assert_raise RuntimeError, fn ->
        required_atom_key_retval(%{foo: :bar})
      end
    end
  end

  def required_integer_key_header(value :: %{required(47) => integer}) do
    value
  end
  def required_integer_key_retval(value) :: %{required(47) => integer} do
    value
  end

  describe "required integer key literal works" do
    test "in the header" do
      assert %{47 => 47} == required_integer_key_header(%{47 => 47})
      assert %{47 => 47, bar: :baz} == required_integer_key_header(%{47 => 47, bar: :baz})
      assert_raise FunctionClauseError, fn ->
        required_integer_key_header([])
      end
      assert_raise FunctionClauseError, fn ->
        required_integer_key_header(%{bar: 47})
      end
      assert_raise FunctionClauseError, fn ->
        required_integer_key_header(%{47 => :bar})
      end
    end
    test "in the retval" do
      assert %{47 => 47} == required_integer_key_retval(%{47 => 47})
      assert %{47 => 47, bar: :baz} == required_integer_key_retval(%{47 => 47, bar: :baz})
      assert_raise RuntimeError, fn ->
        required_integer_key_retval([])
      end
      assert_raise RuntimeError, fn ->
        required_integer_key_retval(%{bar: 47})
      end
      assert_raise RuntimeError, fn ->
        required_integer_key_retval(%{47 => :bar})
      end
    end
  end

  def required_empty_string_key_header(value :: %{required(<<>>) => integer}) do
    value
  end
  def required_empty_string_key_retval(value) :: %{required(<<>>) => integer} do
    value
  end

  describe "required empty string key literal works" do
    test "in the header" do
      assert %{"" => 47} == required_empty_string_key_header(%{"" => 47})
      assert %{"" => 47, bar: :baz} == required_empty_string_key_header(%{"" => 47, bar: :baz})
      assert_raise FunctionClauseError, fn ->
        required_empty_string_key_header([])
      end
      assert_raise FunctionClauseError, fn ->
        required_empty_string_key_header(%{bar: 47})
      end
      assert_raise FunctionClauseError, fn ->
        required_empty_string_key_header(%{"" => :bar})
      end
    end
    test "in the retval" do
      assert %{"" => 47} == required_empty_string_key_retval(%{"" => 47})
      assert %{"" => 47, bar: :baz} == required_empty_string_key_retval(%{"" => 47, bar: :baz})
      assert_raise RuntimeError, fn ->
        required_empty_string_key_retval([])
      end
      assert_raise RuntimeError, fn ->
        required_empty_string_key_retval(%{bar: 47})
      end
      assert_raise RuntimeError, fn ->
        required_empty_string_key_retval(%{"" => :bar})
      end
    end
  end

  def required_empty_list_key_header(value :: %{required([]) => integer}) do
    value
  end
  def required_empty_list_key_retval(value) :: %{required([]) => integer} do
    value
  end

  describe "required empty list key literal works" do
    test "in the header" do
      assert %{[] => 47} == required_empty_list_key_header(%{[] => 47})
      assert %{[] => 47, bar: :baz} == required_empty_list_key_header(%{[] => 47, bar: :baz})
      assert_raise FunctionClauseError, fn ->
        required_empty_list_key_header([])
      end
      assert_raise FunctionClauseError, fn ->
        required_empty_list_key_header(%{bar: 47})
      end
      assert_raise FunctionClauseError, fn ->
        required_empty_list_key_header(%{[] => :bar})
      end
    end
    test "in the retval" do
      assert %{[] => 47} == required_empty_list_key_retval(%{[] => 47})
      assert %{[] => 47, bar: :baz} == required_empty_list_key_retval(%{[] => 47, bar: :baz})
      assert_raise RuntimeError, fn ->
        required_empty_list_key_retval([])
      end
      assert_raise RuntimeError, fn ->
        required_empty_list_key_retval(%{bar: 47})
      end
      assert_raise RuntimeError, fn ->
        required_empty_list_key_retval(%{[] => :bar})
      end
    end
  end

  def required_empty_map_key_header(value :: %{required(%{}) => integer}) do
    value
  end
  def required_empty_map_key_retval(value) :: %{required(%{}) => integer} do
    value
  end

  describe "required empty map key literal works" do
    test "in the header" do
      assert %{%{} => 47} == required_empty_map_key_header(%{%{} => 47})
      assert %{%{} => 47, bar: :baz} == required_empty_map_key_header(%{%{} => 47, bar: :baz})
      assert_raise FunctionClauseError, fn ->
        required_empty_map_key_header(%{})
      end
      assert_raise FunctionClauseError, fn ->
        required_empty_map_key_header(%{bar: 47})
      end
      assert_raise FunctionClauseError, fn ->
        required_empty_map_key_header(%{%{} => :bar})
      end
    end
    test "in the retval" do
      assert %{%{} => 47} == required_empty_map_key_retval(%{%{} => 47})
      assert %{%{} => 47, bar: :baz} == required_empty_map_key_retval(%{%{} => 47, bar: :baz})
      assert_raise RuntimeError, fn ->
        required_empty_map_key_retval(%{})
      end
      assert_raise RuntimeError, fn ->
        required_empty_map_key_retval(%{bar: 47})
      end
      assert_raise RuntimeError, fn ->
        required_empty_map_key_retval(%{%{} => :bar})
      end
    end
  end

  def required_empty_tuple_key_header(value :: %{required({}) => integer}) do
    value
  end
  def required_empty_tuple_key_retval(value) :: %{required({}) => integer} do
    value
  end

  describe "required empty tuple key literal works" do
    test "in the header" do
      assert %{{} => 47} == required_empty_tuple_key_header(%{{} => 47})
      assert %{{} => 47, bar: :baz} == required_empty_tuple_key_header(%{{} => 47, bar: :baz})
      assert_raise FunctionClauseError, fn ->
        required_empty_tuple_key_header(%{})
      end
      assert_raise FunctionClauseError, fn ->
        required_empty_tuple_key_header(%{bar: 47})
      end
      assert_raise FunctionClauseError, fn ->
        required_empty_tuple_key_header(%{{} => :bar})
      end
    end
    test "in the retval" do
      assert %{{} => 47} == required_empty_tuple_key_retval(%{{} => 47})
      assert %{{} => 47, bar: :baz} == required_empty_tuple_key_retval(%{{} => 47, bar: :baz})
      assert_raise RuntimeError, fn ->
        required_empty_tuple_key_retval(%{})
      end
      assert_raise RuntimeError, fn ->
        required_empty_tuple_key_retval(%{bar: 47})
      end
      assert_raise RuntimeError, fn ->
        required_empty_tuple_key_retval(%{{} => :bar})
      end
    end
  end

  def required_nonliteral_key_header(value :: %{required(atom) => integer}) do
    value
  end
  def required_nonliteral_key_retval(value) :: %{required(atom) => integer} do
    value
  end

  describe "required nonliteral works" do
    test "in the header" do
      assert %{foo: 47} == required_nonliteral_key_header(%{foo: 47})
      assert %{foo: 47, bar: 42} == required_nonliteral_key_header(%{foo: 47, bar: 42})
      assert %{:foo => 47, "bar" => :baz} == required_nonliteral_key_header(%{:foo => 47, "bar" => :baz})
      assert_raise FunctionClauseError, fn ->
        required_nonliteral_key_header([])
      end
      assert_raise FunctionClauseError, fn ->
        required_nonliteral_key_header(%{foo: :bar})
      end
      assert_raise FunctionClauseError, fn ->
        required_nonliteral_key_header(%{foo: 47, bar: :baz})
      end
    end
    test "in the retval" do
      assert %{foo: 47} == required_nonliteral_key_retval(%{foo: 47})
      assert %{foo: 47, bar: 42} == required_nonliteral_key_retval(%{foo: 47, bar: 42})
      assert %{:foo => 47, "bar" => :baz} == required_nonliteral_key_retval(%{:foo => 47, "bar" => :baz})
      assert_raise RuntimeError, fn ->
        required_nonliteral_key_retval([])
      end
      assert_raise RuntimeError, fn ->
        required_nonliteral_key_retval(%{foo: :bar})
      end
      assert_raise RuntimeError, fn ->
        required_nonliteral_key_retval(%{foo: 47, bar: :baz})
      end
    end
  end

  def optional_nonliteral_key_header(value :: %{optional(atom) => integer}) do
    value
  end
  def optional_nonliteral_key_retval(value) :: %{optional(atom) => integer} do
    value
  end

  describe "optional nonliteral works" do
    test "in the header" do
      assert %{} == optional_nonliteral_key_header(%{})
      assert %{foo: 47} == optional_nonliteral_key_header(%{foo: 47})
      assert %{foo: 47, bar: 42} == optional_nonliteral_key_header(%{foo: 47, bar: 42})
      assert_raise FunctionClauseError, fn ->
        optional_nonliteral_key_header([])
      end
      assert_raise FunctionClauseError, fn ->
        optional_nonliteral_key_header(%{foo: :bar})
      end
      assert_raise FunctionClauseError, fn ->
        optional_nonliteral_key_header(%{foo: 47, bar: :baz})
      end
    end
    test "in the retval" do
      assert %{} == optional_nonliteral_key_retval(%{})
      assert %{foo: 47} == optional_nonliteral_key_retval(%{foo: 47})
      assert %{foo: 47, bar: 42} == optional_nonliteral_key_retval(%{foo: 47, bar: 42})
      assert_raise RuntimeError, fn ->
        optional_nonliteral_key_retval([])
      end
      assert_raise RuntimeError, fn ->
        optional_nonliteral_key_retval(%{foo: :bar})
      end
      assert_raise RuntimeError, fn ->
        optional_nonliteral_key_retval(%{foo: 47, bar: :baz})
      end
    end
  end
end
