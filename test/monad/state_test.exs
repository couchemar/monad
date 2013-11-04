defmodule Monad.StateTest do
  use ExUnit.Case, async: true

  require Monad.State, as: State
  import State

  doctest State

  test "Monad.State left identity" do
    f = fn (x) -> return(x * x) end
    a = 2
    assert run(10, bind(return(a), f)) == run(10, f.(a))
  end

  test "Monad.State right identity" do
    m = return 42
    assert run(10, bind(m, &return/1)) == run(10, m)
  end

  test "Monad.State associativity" do
    f = fn (x) -> return(x * x) end
    g = fn (x) -> return(x - 1) end
    m = return 2
    assert run(10, bind(m, f) |> bind(g)) == run(10, bind(m, &bind(f.(&1), g)))
  end

  test "Monad.State get and put" do
    assert run(4, (State.m do
                     let x = 2
                     y <- get
                     put x
                     return (x * y)
                   end)) == {8, 2}
  end

  test "Monad.State modify" do
    assert run(4, modify(&(&1+1))) == {nil, 5}
  end
end
