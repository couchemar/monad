defmodule Monad.Either do
  use Monad.Behaviour

  @moduledoc """
  The Either monad.

  Allows shortcutting computations.

  Works on values of the form `{:left, reason}` | `{:right, value}`.  If a left
  value is passed to bind it is immediately returned, if a right value is passed
  the value inside the tuple is given to the function passed to bind.

  ## Examples

      iex> use Monad
      iex> alias Monad.Either
      iex> m Either do
      ...>   a <- return 1
      ...>   b <- return 2
      ...>   return a + b
      ...> end
      right 3

      iex> alias Monad.Either
      iex> m Either do
      ...>   a <- fail "aborted"
      ...>   b <- return 1
      ...>   return a + b
      ...> end
      left "aborted"
  """

  @opaque left :: {:left, any}
  @opaque right :: {:right, any}
  @type either :: left | right

  ## Monad implementations

  @spec bind(either, (any -> any)) :: either
  def bind(l = {:left, _}, _), do: l
  def bind({:right, x}, f), do: f.(x)

  @doc """
  Injects `x` into an Either monad.
  """
  @spec return(any) :: either
  def return(x), do: {:right, x}

  ## Auxiliary functions

  @doc """
  Signal failure.
  """
  @spec fail(any) :: either
  def fail(reason), do: {:left, reason}

  @doc """
  Turns `x` into a `left` value.
  """
  defmacro left(x) do
    quote do
      {:left, unquote(x)}
    end
  end

  @doc """
  Turns `x` into a `right` value.
  """
  defmacro right(x) do
    quote do
      {:right, unquote(x)}
    end
  end

  @doc """
  Returns `f(x)` if `m` is `left x` or `g(x)` if `m` is `right x`.

  ## Example

      iex> either(left(2), &(&1 - 1), &(&1 + 1))
      1

      iex> either(right(2), &(&1 - 1), &(&1 + 1))
      3
  """
  @spec either(either, (any -> any), (any -> any)) :: any
  def either(m, f, g)
  def either({:left, x}, f, _), do: f.(x)
  def either({:right, y}, _, g), do: g.(y)
end
