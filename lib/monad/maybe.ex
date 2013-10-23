defmodule Monad.Maybe do
  use Monad.Behaviour

  @moduledoc """
  The Maybe monad.

  Allows for computations that return an optional value.

  Works on values of the form `{:just, value}` and `:nothing`. If a nothing is
  passed to bind it is returned immediately. If a just value is passed to bind
  the value inside the tuple is given to the function passed to bind.

  ## Examples

      iex> use Monad
      iex> alias Monad.Maybe
      iex> m Maybe do
      ...>   x <- just 1
      ...>   y <- just 2
      ...>   return x + y
      ...> end
      just 3

      iex> alias Monad.Maybe
      iex> m Maybe do
      ...>   x <- just 1
      ...>   y <- nothing
      ...>   return x + y
      ...> end
      nothing
  """

  ## Monad implementations

  def bind(m, f)
  def bind({:just, x}, f), do: f.(x)
  def bind(:nothing, _), do: :nothing

  def return(x), do: {:just, x}

  ## Auxiliary functions

  @doc """
  Alias for `nothing/1`
  """
  def fail(_), do: nothing

  @doc """
  Returns `just x`.
  """
  def just(x), do: return(x)

  @doc """
  Returns `nothing`.
  """
  def nothing, do: :nothing

  @doc """
  Call function `f` with the value inside the maybe value `m` if `m` is `just`,
  otherwise call function `f` with default value `d`.
  """
  def maybe(d, f, m)
  def maybe(_, f, {:just, x}), do: f.(x)
  def maybe(d, f, :nothing), do: f.(d)

  @doc """
  Returns true if given `just x` and false if given `nothing`.
  """
  def is_just({:just, _}), do: true
  def is_just(:nothing), do: false

  @doc """
  Returns true if given the nothing value and false if given a just value.
  """
  def is_nothing(:nothing), do: true
  def is_nothing({:just, _}), do: false

  @doc """
  Returns the value inside a just, raises an error if given the nothing value.
  """
  def from_just(m)
  def from_just({:just, x}), do: x
  def from_just(:nothing), do: raise "Monad.Maybe.from_just: nothing"

  @doc """
  Returns the value inside a just, or the given default when given nothing.
  """
  def from_maybe(d, m)
  def from_maybe(_, {:just, x}), do: x
  def from_maybe(d, :nothing), do: d

  @doc """
  Converts maybe value `m` to a list.

  Returns an empty list when given the nothing value, return a list of one
  elemnt containg the value inside the just when given a just value.
  """
  def maybe_to_list(m)
  def maybe_to_list({:just, x}), do: [x]
  def maybe_to_list(:nothing), do: []

  @doc """
  Converts list `l` to a maybe value.

  Returns `nothing` if given an empty list; returns `just x` when given the
  nonempty list `l`, where `x` is the head of `l`.
  """
  def list_to_maybe(l)
  def list_to_maybe([x | _]), do: just x
  def list_to_maybe([]), do: nothing

  @doc """
  Takes a list of `maybe`s and returns a list of all the `just` values.
  """
  def cat_maybes(l) do
    lc x inlist l, is_just(x), do: from_just x
  end

  @doc """
  Map function `f` over the list `l` and throw out elements for which `f`
  returns `nothing`.
  """
  def map_maybes(f, l) do
    lc x inlist l, is_just(f.(x)), do: from_just f.(x)
  end
end
