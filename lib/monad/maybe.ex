defmodule Monad.Maybe do
  def bind({:just, x}, f), do: f.(x)
  def bind(:nothing, _), do: :nothing

  def return(x), do: {:just, x}

  def fail(_), do: :nothing

  def just(x), do: return(x)

  def nothing, do: :nothing

  def is_just({:just, _}), do: true
  def is_just(_), do: false
end
