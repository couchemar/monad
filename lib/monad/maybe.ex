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

  @opaque just :: {:just, any}
  @opaque nothing :: :nothing
  @type maybe :: just | nothing

  ## Monad implementations

  @spec bind(maybe, (any -> any)) :: maybe
  def bind(m, f)
  def bind({:just, x}, f), do: f.(x)
  def bind(:nothing, _), do: :nothing

  @doc """
  Injects `x` into a Maybe monad.
  """
  @spec return(any) :: maybe
  def return(x), do: {:just, x}

  ## Auxiliary functions

  @doc """
  Alias for `nothing/1`
  """
  @spec fail(any) :: nothing
  def fail(_), do: :nothing

  @doc """
  Returns `just x`.
  """
  defmacro just(x) do
    quote do
      {:just, unquote(x)}
    end
  end

  @doc """
  Returns `nothing`.
  """
  defmacro nothing do
    quote do: :nothing
  end

  @doc """
  Call function `f` with the value inside the maybe value `m` if `m` is `just`,
  otherwise call function `f` with default value `d`.
  """
  @spec maybe(any, (any -> any), maybe) :: any
  def maybe(d, f, m)
  def maybe(_, f, {:just, x}), do: f.(x)
  def maybe(d, f, :nothing), do: f.(d)

  @doc """
  Returns true if given `just x` and false if given `nothing`.
  """
  @spec is_just(maybe) :: boolean
  def is_just({:just, _}), do: true
  def is_just(:nothing), do: false

  @doc """
  Returns true if given the nothing value and false if given a just value.
  """
  @spec is_nothing(maybe) :: boolean
  def is_nothing(:nothing), do: true
  def is_nothing({:just, _}), do: false

  @doc """
  Extracts the value out of a `just` and raises an error if given the nothing
  value.
  """
  @spec from_just(maybe) :: any
  def from_just(m)
  def from_just({:just, x}), do: x
  def from_just(:nothing), do: raise "Monad.Maybe.from_just: nothing"

  @doc """
  Returns the value inside a just, or the given default when given nothing.
  """
  @spec from_maybe(any, maybe) :: any
  def from_maybe(d, m)
  def from_maybe(_, {:just, x}), do: x
  def from_maybe(d, :nothing), do: d

  @doc """
  Converts maybe value `m` to a list.

  Returns an empty list when given the nothing value, return a list of one
  elemnt containg the value inside the just when given a just value.
  """
  @spec maybe_to_list(maybe) :: [any]
  def maybe_to_list(m)
  def maybe_to_list({:just, x}), do: [x]
  def maybe_to_list(:nothing), do: []

  @doc """
  Converts list `l` to a maybe value.

  Returns `nothing` if given an empty list; returns `just x` when given the
  nonempty list `l`, where `x` is the head of `l`.
  """
  @spec list_to_maybe([any]) :: maybe
  def list_to_maybe(l)
  def list_to_maybe([x | _]), do: just x
  def list_to_maybe([]), do: nothing

  @doc """
  Takes a list of `maybe`s and returns a list of all the `just` values.

  ## Example

      iex> cat_maybes [just(1), nothing, just(2), nothing, just(3)]
      [1, 2, 3]

  """
  @spec cat_maybes([maybe]) :: [any]
  def cat_maybes(l) do
    lc x inlist l, is_just(x), do: from_just x
  end

  @doc """
  Map function `f` over the list `l` and throw out elements for which `f`
  returns `nothing`.
  """
  @spec map_maybes((any -> maybe), [any]) :: [any]
  def map_maybes(f, l) do
    lc x inlist l, is_just(f.(x)), do: from_just f.(x)
  end
end
