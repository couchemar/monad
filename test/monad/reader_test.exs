defmodule Monad.ReaderTest do
  use ExUnit.Case, async: true

  use Monad
  import Monad.Reader
  alias Monad.Reader
  require Reader

  doctest Monad.Reader

  test "Monad.Reader left identity" do
    f = fn (x) -> return(x * x) end
    a = 2
    assert run(10, bind(return(a), f)) == run(10, f.(a))
  end

  test "Monad.Reader right identity" do
    m = return 42
    assert run(10, bind(m, &return/1)) == run(10, m)
  end

  test "Monad.Reader associativity" do
    f = fn (x) -> return(x * x) end
    g = fn (x) -> return(x - 1) end
    m = return 2
    assert run(10, bind(m, f) |> bind(g)) == run(10, bind(m, &bind(f.(&1), g)))
  end

  test "Monad.Reader pipeline" do
    assert run(10, (pl Reader, (ask |> (&return(&1+1)).()))) == 11
  end

  test "Monad.Reader ask" do
    assert run(4, (Reader.m do
                     x <- return 2
                     y <- ask
                     return (x * y)
                   end)) == 8
  end

  test "Monad.Reader local" do
    assert run(4, (local(ask, &(&1+1)))) == 5
  end
end
