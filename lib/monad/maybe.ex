defmodule Monad.Maybe do
  use Monad.Behaviour

  @moduledoc """
  The Maybe monad.

  The `Maybe` monad encapsulates an optional value. A `maybe` monad either
  contains a value `x` (represented as "`just x`") or is empty (represented as
  "`nothing`").

  `Maybe` is a simple kind of error monad, where all errors are represented by
  `nothing`.

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
      ...>   y <- :nothing
      ...>   return x + y
      ...> end
      :nothing
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
  Signal failure.
  """
  @spec fail(any) :: maybe
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
  Returns true if given `nothing` value and false if given `just x`.
  """
  @spec is_nothing(maybe) :: boolean
  def is_nothing(:nothing), do: true
  def is_nothing({:just, _}), do: false

  @doc """
  Extracts the value out of a `just` or raises an error if given `nothing`.
  """
  @spec from_just(maybe) :: any
  def from_just(m)
  def from_just({:just, x}), do: x
  def from_just(:nothing), do: raise "Monad.Maybe.from_just: nothing"

  @doc """
  Extracts the value out a `just` or returns default `d` if given `nothing`.
  """
  @spec from_maybe(any, maybe) :: any
  def from_maybe(d, m)
  def from_maybe(_, {:just, x}), do: x
  def from_maybe(d, :nothing), do: d

  @doc """
  Converts maybe value `m` to a list.

  Returns an empty list if given `nothing` or returns a list that contains the
  value of a `just`.

  ## Examples

      iex> maybe_to_list :nothing
      []

      iex> maybe_to_list just(42)
      [42]

  """
  @spec maybe_to_list(maybe) :: [any]
  def maybe_to_list(m)
  def maybe_to_list({:just, x}), do: [x]
  def maybe_to_list(:nothing), do: []

  @doc """
  Converts list `l` to a maybe value.

  Returns `nothing` if given the empty list; returns `just x` when given the
  nonempty list `l`, where `x` is the head of `l`.

  ## Examples

      iex> list_to_maybe []
      :nothing

      iex> list_to_maybe [1, 2, 3]
      just 1

  """
  @spec list_to_maybe([any]) :: maybe
  def list_to_maybe(l)
  def list_to_maybe([x | _]), do: just x
  def list_to_maybe([]), do: :nothing

  @doc """
  Takes a list of `maybe`s and returns a list of all the `just` values.

  ## Example

      iex> cat_maybes [just(1), :nothing, just(2), :nothing, just(3)]
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
