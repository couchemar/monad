defmodule Monad.Maybe do
  def bind({:just, x}, f) do
    f.(x)
  end
  def bind(:nothing, _) do
    :nothing
  end

  def return(x) do
    {:just, x}
  end
end
