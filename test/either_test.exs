defmodule EitherTest do
  use ExUnit.Case, async: true
  import Monad
  import Monad.Either

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
    assert (m_do Monad.Either do
              x <- right 2
              return x * x
            end) == {:right, 4}
  end

  test "Monad.Either failing bind" do
    assert (m_do Monad.Either do
              x <- left 2
              return x * x
            end) == {:left, 2}
  end

  test "Monad.Either.fail" do
    assert (m_do Monad.Either do
              x <- fail "reason"
              return x * x
            end) == {:left, "reason"}
  end

  test "Monad.Either.either/3 with left value" do
    assert either(&(&1 * 2), &(&1 * &1), left 4) == 8
  end

  test "Monad.Either.either/3 with right value" do
    assert either(&(&1 * 2), &(&1 * &1), right 4) == 16
  end
end
