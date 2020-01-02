defmodule UnalteredTest do
  use ExUnit.Case, async: true

  use TypedHeaders

  def identity(value) do
    value
  end

  test "an unaltered header works as expected" do
    assert 47 == identity(47)
    assert "47" == identity("47")
  end

  def zeroarity(), do: 47
  def zeroarity_2, do: 47

  test "zero arity functions work" do
    assert 47 == zeroarity()
    assert 47 == zeroarity_2()
  end

end
