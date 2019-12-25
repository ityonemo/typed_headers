defmodule UnalteredTest do
  use ExUnit.Case, async: true

  defmodule UnTyped do
    use TypedHeaders
    def identity(value) do
      value
    end
  end

  test "an unaltered header works as expected" do
    assert 47 == UnTyped.identity(47)
    assert "47" == UnTyped.identity("47")
  end

end
