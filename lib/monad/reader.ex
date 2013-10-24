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
  @opaque reader :: ((any) -> any)

  ## Monad implementations

  @spec bind(reader, ((any) -> reader)) :: reader
  def bind(r, f), do: fn x -> f.(r.(x)).(x) end

  @spec return(any) :: reader
  def return(x), do: fn _ -> x end 

  ## Other functions

  @doc """
  Run the reader by supplying the given value to it.
  """
  @spec run(any, reader) :: any
  def run(x, r), do: r.(x)

  @doc """
  Ask for the reader's value.
  """
  @spec ask() :: reader
  def ask(), do: fn x -> x end 

  @doc """
  Locally set a different value for the reader.
  """
  @spec local(reader, ((any) -> any)) :: reader
  def local(r, f), do: fn x -> r.(f.(x)) end
end
