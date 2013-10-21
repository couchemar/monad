defmodule Monad.Either do
  def bind(l = {:left, _}, _), do: l
  def bind({:right, x}, f), do: f.(x)

  def return(x), do: right(x)

  def fail(r), do: left(r)

  def left(x), do: {:left, x}

  def right(x), do: {:right, x}

  def either(f, _, {:left, x}), do: f.(x)
  def either(_, g, {:right, y}), do: g.(y)
end
