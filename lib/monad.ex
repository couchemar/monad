defmodule Monad do
  defmacro m(mod_name, do: block) do
    monad = Macro.expand(mod_name, __CALLER__)
    case block do
      {:__block__, _, actions} ->
        expand(monad, actions)
      action ->
        action
    end
  end

  defp expand(_, [action]) do
    action
  end

  defp expand(monad, [{:<-, _, [pattern, action]} | actions]) do
    quote do
      f = fn unquote(pattern) ->
               unquote(expand(monad, actions))
          end
      unquote(monad).bind(unquote(action), f)
    end
  end
  defp expand(monad, [action | actions]) do
    quote do
      f = fn (_) -> unquote(expand(monad, actions)) end
      unquote(monad).bind(unquote(action), f)
    end
  end
end
