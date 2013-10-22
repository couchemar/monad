defmodule Monad.EitherTest do
  use ExUnit.Case, async: true

  use Monad
  import Monad.Either

  doctest Monad.Either

  test "Monad.Either left identity" do
    f = fn (x) -> x * x end
    a = 2
    assert bind(return(a), f) == f.(a)
  end

  test "Monad.Either right identity" do
    m = return 42
    assert bind(m, &return/1) == m
  end

  test "Monad.Either associativity" do
    f = fn (x) -> x * x end
    g = fn (x) -> x - 1 end
    m = return 2
    assert bind(return(bind(m, f)), g) == bind(m, &bind(return(f.(&1)), g))
  end

  test "Monad.Either successful bind" do
    assert (m Monad.Either do
              x <- right 2
              return x * x
            end) == {:right, 4}
  end

  test "Monad.Either failing bind" do
    assert (m Monad.Either do
              x <- left 2
              return x * x
            end) == {:left, 2}
  end

  test "Monad.Either pipeline" do
    assert (pl Monad.Either, ({:right, 2} |> (&{:right, &1+2}).()))
           == {:right, 4}
  end

  test "Monad.Either pipeline fail" do
    assert (pl Monad.Either, ({:left, 2} |> (&{:right, &1+2}).()))
           == {:left, 2}
  end

  defp either_invert(x), do: Monad.Either.return(-x)

  defp either_add_n(x, y), do: Monad.Either.return(x + y)

  test "Monad.Either pipeline multiple and call without parens" do
    assert (pl Monad.Either,
               ({:right, 2} |> either_invert |> either_add_n(3)))
           == {:right, 1}
  end

  test "Monad.Either pipeline with do" do
    assert (pl Monad.Either do
              {:right, 2} |> either_invert |> either_add_n(3)
            end) == {:right, 1}
  end

  test "Monad.Either.fail" do
    assert (m Monad.Either do
              x <- fail "reason"
              return x * x
            end) == {:left, "reason"}
  end

  test "Monad.Either.either/3 with left value" do
    assert either(left(4), &(&1 * 2), &(&1 * &1)) == 8
  end

  test "Monad.Either.either/3 with right value" do
    assert either(right(4), &(&1 * 2), &(&1 * &1)) == 16
  end
end
