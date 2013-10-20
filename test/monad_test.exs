defmodule MonadTest do
  use ExUnit.Case
  import Monad
  import Monad.Maybe

  test "Maybe monad bind success" do
    assert (m_do Monad.Maybe do
              x <- return 2
              y <- return 4
              return (x * y)
            end) == {:just, 8}
  end

  test "Maybe monad bind fail" do
    assert (m_do Monad.Maybe do
              x <- return 2
              y <- fail "Yes, we can"
              return (x * y)
            end) == :nothing
  end
end
