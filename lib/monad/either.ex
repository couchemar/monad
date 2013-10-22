defmodule Monad.Either do
  @behaviour Monad

  @moduledoc """
  The Either monad.

  Allows shortcutting computations.

  Works on values of the form `{ :left, reason }` | `{ :right, value }`.
  If a left value is passed to bind it is immediately returned, if a right value
  is passed the value inside the tuple is given to the function passed to bind.

  ## Examples
  
      iex> require Monad
      iex> import Monad, only: [m: 2]
      iex> alias Monad.Either
      
      iex> Monad.m Monad.Either do 
      ...>   a <- { :right, 1 }
      ...>   b <- return 2
      ...>   return a + b
      ...> end
      { :right, 3 }
      
      iex> import Monad, only: [m: 2]
      iex> alias Monad.Either
      iex> Monad.m Monad.Either do 
      ...>   a <- { :left, "aborted" }
      ...>   b <- { :right, 1 }
      ...>   return a + b
      ...> end
      { :left, "aborted" }
  """

  ## Monad implementations

  def bind(l = {:left, _}, _), do: l
  def bind({:right, x}, f), do: f.(x)

  def return(x), do: right(x)

  ## Auxiliary functions

  @doc """
  Alias for `left/1`.
  """
  def fail(r), do: left(r)

  @doc """
  Wraps a value in a `{ :left, value }` tuple.
  """
  def left(x), do: {:left, x}

  @doc """
  Wraps a value in a `{ :right, value }` tuple.
  """
  def right(x), do: {:right, x}

  @doc """
  If `e` is a `{ :left, v }` tuple `on_left` with `v`.
  If `e` is a `{ :right, v }` tuple `on_right` with `v`.
  """
  def either(e, on_left, on_right)
  def either({:left, x}, f, _), do: f.(x)
  def either({:right, y}, _, g), do: g.(y)
end
