defmodule Monad.ErrorTest do
  use ExUnit.Case, async: true

  use Monad
  import Monad.Error

  doctest Monad.Error

  test "Monad.Error error identity" do
    f = fn (x) -> x * x end
    a = 2
    assert bind(return(a), f) == f.(a)
  end

  test "Monad.Error ok identity" do
    m = return 42
    assert bind(m, &return/1) == m
  end

  test "Monad.Error associativity" do
    f = fn (x) -> x * x end
    g = fn (x) -> x - 1 end
    m = return 2
    assert bind(return(bind(m, f)), g) == bind(m, &bind(return(f.(&1)), g))
  end

  test "Monad.Error successful bind" do
    assert (m Monad.Error do
              x <- {:ok, 2}
              return x * x
            end) == {:ok, 4}
  end

  test "Monad.Error failing bind" do
    assert (m Monad.Error do
              x <- {:error, 2}
              return x * x
            end) == {:error, 2}
  end

  test "Monad.Error pipeline" do
    assert (pl Monad.Error, ({:ok, 2} |> (&{:ok, &1+2}).()))
           == {:ok, 4}
  end

  test "Monad.Error pipeline fail" do
    assert (pl Monad.Error, ({:error, 2} |> (&{:ok, &1+2}).()))
           == {:error, 2}
  end

  defp error_invert(x), do: Monad.Error.return(-x)

  defp error_add_n(x, y), do: Monad.Error.return(x + y)

  test "Monad.Error pipeline multiple and call without parens" do
    assert (pl Monad.Error,
               ({:ok, 2} |> error_invert |> error_add_n(3)))
           == {:ok, 1}
  end

  test "Monad.Error pipeline with do" do
    assert (pl Monad.Error do
              {:ok, 2} |> error_invert |> error_add_n(3)
            end) == {:ok, 1}
  end

  test "Monad.Error.fail" do
    assert (m Monad.Error do
              x <- fail "reason"
              return x * x
            end) == {:error, "reason"}
  end
end
