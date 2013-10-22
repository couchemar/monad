defmodule Monad.Maybe do
  use Monad.Behaviour

  def bind({:just, x}, f), do: f.(x)
  def bind(:nothing, _), do: :nothing

  def return(x), do: {:just, x}

  def fail(_), do: :nothing

  def just(x), do: return(x)

  def nothing, do: :nothing

  def maybe(_, f, {:just, x}), do: f.(x)
  def maybe(d, f, :nothing), do: f.(d)

  def is_just({:just, _}), do: true
  def is_just(_), do: false

  def is_nothing(:nothing), do: true
  def is_nothing(_), do: false

  def from_just({:just, x}), do: x
  def from_just(:nothing), do: raise "Monad.Maybe.from_just: nothing"

  def from_maybe(_, {:just, x}), do: x
  def from_maybe(d, :nothing), do: d

  def maybe_to_list({:just, x}), do: [x]
  def maybe_to_list(:nothing), do: []

  def list_to_maybe([x | _]), do: just x
  def list_to_maybe([]), do: nothing

  def cat_maybes(l) do
    lc x inlist l, is_just(x), do: from_just x
  end

  def map_maybes(f, l) do
    lc x inlist l, is_just(f.(x)), do: from_just f.(x)
  end
end
