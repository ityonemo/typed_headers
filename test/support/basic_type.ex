defmodule BasicType do
  @type t :: String.t
  @type i :: 47
  @type a :: :foo
  @type r :: 42..47
  @type tup :: {:foo, :bar}
  @type union :: integer | String.t
  @type m :: %{foo: integer}
  @type om :: %{optional(:foo) => integer}
  @type l :: [String.t]
end
