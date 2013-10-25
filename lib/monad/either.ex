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
      ...>   a <- {:right, 1}
      ...>   b <- return 2
      ...>   return a + b
      ...> end
      {:right, 3}

      iex> alias Monad.Either
      iex> m Either do
      ...>   a <- {:left, "aborted"}
      ...>   b <- {:right, 1}
      ...>   return a + b
      ...> end
      {:left, "aborted"}
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
  Returns `left x`.
  """
  defmacro left(x) do
    quote do
      {:left, unquote(x)}
    end
  end

  @doc """
  Returns `right x`.
  """
  defmacro right(x) do
    quote do
      {:right, unquote(x)}
    end
  end

  @doc """
  If `e` is a `{:left, v}` tuple `on_left` with `v`.
  If `e` is a `{:right, v}` tuple `on_right` with `v`.
  """
  @spec either(either, (any -> any), (any -> any)) :: any
  def either(e, on_left, on_right)
  def either({:left, x}, f, _), do: f.(x)
  def either({:right, y}, _, g), do: g.(y)
end
