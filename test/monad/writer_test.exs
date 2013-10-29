defmodule WList do
  use Monad.Writer
  def initial, do: []
  def combine(new, acc), do: acc ++ new
end

defmodule Monad.WriterTest do
  use ExUnit.Case, async: true

  use Monad

  doctest Monad.Writer

  import WList

  test "Monad.Writer left identity" do
    f = fn (x) -> return(x * x) end
    a = 2
    assert run(bind(return(a), f)) == run(f.(a))
  end

  test "Monad.Writer right identity" do
    m = return 42
    assert run(bind(m, &return/1)) == run(m)
  end

  test "Monad.Writer associativity" do
    f = fn (x) -> return(x * x) end
    g = fn (x) -> return(x - 1) end
    m = return 2
    assert run(bind(m, f) |> bind(g)) == run(bind(m, &bind(f.(&1), g)))
  end

  test "Monad.Writer tell" do
    assert run(WList.m do
                 x <- return 2
                 tell [3]
                 tell [4]
                 return x
               end) == {2, [3,4]}
  end
end
