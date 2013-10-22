defmodule Monad.Error do
  use Monad.Behaviour

  @moduledoc """
  The Error monad.

  Allows shortcutting computations in typical Elixir/Erlang style.

  Works on values of the form `{:error, reason}` | `{:ok, value}`.  If an error
  value is passed to bind it is immediately returned, if an ok value is passed
  the value inside the tuple is given to the function passed to bind.

  ## Examples

      iex> use Monad
      iex> alias Monad.Error
      iex> m Error do
      ...>   a <- {:ok, 1}
      ...>   b <- return 2
      ...>   return a + b
      ...> end
      {:ok, 3}

      iex> alias Monad.Error
      iex> m Error do
      ...>   a <- {:error, "aborted"}
      ...>   b <- {:ok, 1}
      ...>   return a + b
      ...> end
      {:error, "aborted"}
  """

  ## Monad implementations

  def bind(e = {:error, _}, _), do: e
  def bind({:ok, x}, f), do: f.(x)

  def return(x), do: ok(x)

  ## Auxiliary functions

  @doc """
  Alias for `error/1`.
  """
  def fail(r), do: error(r)

  @doc """
  Wraps a value in a `{:error, value}` tuple.
  """
  def error(x), do: {:error, x}

  @doc """
  Wraps a value in a `{:ok, value}` tuple.
  """
  def ok(x), do: {:ok, x}
end
