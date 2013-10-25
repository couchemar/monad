defmodule Monad.Reader do
  use Monad.Behaviour

  @moduledoc """
  The Reader monad.

  Allows passing read-only values "under the hood". 

  ## Examples

      iex> use Monad
      iex> alias Monad.Reader
      iex> r = m Reader do
      ...>       a <- return 2 
      ...>       b <- ask
      ...>       return a + b
      ...>     end
      iex> Reader.run(10, r)
      12
  """
 
  # A reader is just a function that receives the "under the hood" value.
  @opaque m :: ((any) -> any)

  ## Monad implementations

  @spec bind(m, ((any) -> m)) :: m
  def bind(r, f), do: fn x -> f.(r.(x)).(x) end

  @spec return(any) :: m
  def return(x), do: fn _ -> x end 

  ## Other functions

  @doc """
  Run the reader by supplying the given value to it.
  """
  @spec run(any, m) :: any
  def run(x, r), do: r.(x)

  @doc """
  Ask for the reader's value.
  """
  @spec ask() :: m
  def ask(), do: fn x -> x end 

  @doc """
  Locally set a different value for the reader.
  """
  @spec local(m, ((any) -> any)) :: m
  def local(r, f), do: fn x -> r.(f.(x)) end
end
