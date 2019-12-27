defmodule TypedHeaders.MultilineBlockTest do
  use ExUnit.Case, async: true
  use TypedHeaders

  def test_function(value :: integer) :: integer do
    mod = value + 1
    mod * 2
  end

  test "guards work for multiline functions" do
    assert 4 == test_function(1)
  end
end
