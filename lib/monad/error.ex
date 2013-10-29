defmodule Monad.Error do
  use Monad.Behaviour
  use Monad.Pipeline

  @moduledoc """
  The Error monad.

  Allows shortcutting computations in typical Elixir/Erlang style.

  Works on values of the form `{:error, reason}` | `{:ok, value}`.  If an error
  value is passed to bind it is immediately returned, if an ok value is passed
  the value inside the tuple is given to the function passed to bind.

  ## Examples

      iex> alias Monad.Error
      iex> require Error
      iex> Error.m do
      ...>   a <- {:ok, 1}
      ...>   b <- return 2
      ...>   return a + b
      ...> end
      {:ok, 3}

      iex> alias Monad.Error
      iex> require Error
      iex> Error.m do
      ...>   a <- {:error, "aborted"}
      ...>   b <- {:ok, 1}
      ...>   return a + b
      ...> end
      {:error, "aborted"}
  """

  @type error_m :: {:error, any} | {:ok, any}

  ## Monad implementations

  @spec bind(error_m, (any -> any)) :: error_m
  def bind(m, f)
  def bind(e = {:error, _}, _), do: e
  def bind({:ok, x}, f), do: f.(x)

  @spec return(any) :: error_m
  def return(x), do: {:ok, x}

  ## Auxiliary functions

  @doc """
  Signal failure.
  """
  @spec fail(any) :: error_m
  def fail(msg), do: {:error, msg}
end
