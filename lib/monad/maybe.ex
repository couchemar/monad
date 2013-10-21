defmodule Monad.Maybe do
  def bind({:just, x}, f), do: f.(x)
  def bind(:nothing, _), do: :nothing

  def return(x), do: {:just, x}

  def fail(_), do: :nothing

  def just(x), do: return(x)

  def nothing, do: :nothing

  def maybe(_, f, {:just, x}), do: f.(x)
  def maybe(y, f, :nothing), do: f.(y)

  def is_just({:just, _}), do: true
  def is_just(_), do: false

  def is_nothing(:nothing), do: true
  def is_nothing(_), do: false
end
