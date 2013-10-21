defmodule Monad do
  def expand(_, [action]) do
    action
  end

  def expand(monad, [{:<-, _, [pattern, action]} | actions]) do
    quote do
      f = fn unquote(pattern) ->
               unquote(expand(monad, actions))
          end
      unquote(monad).bind(unquote(action), f)
    end
  end
  def expand(monad, [action | actions]) do
    quote do
      f = fn (_) -> unquote(expand(monad, actions)) end
      unquote(monad).bind(unquote(action), f)
    end
  end

  defmacro m_do(mod_name, do: block) do
    monad = Macro.expand(mod_name, __CALLER__)
    case block do
      {:__block__, _, actions} ->
        expand(monad, actions)
      action ->
        action
    end
  end
end
