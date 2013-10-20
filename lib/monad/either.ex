defmodule Monad.Either do
  def bind(l = {:left, _}, _), do: l
  def bind({:right, x}, f), do: f.(x)

  def return(x), do: right(x)

  def left(x), do: {:left, x}

  def right(x), do: {:right, x}
end
