defmodule Monad do
  use Behaviour

  defmacro m(mod, do: block) do
    monad_do_notation(mod, block)
    # monad = Macro.expand(mod_name, __CALLER__)
    # case block do
    #   {:__block__, _, actions} ->
    #     expand(monad, actions)
    #   action ->
    #     action
    # end
  end

  def monad_do_notation(mod, do_block)
  def monad_do_notation(_, nil) do
    raise ArgumentError, message: "no or empty do block"
  end
  def monad_do_notation(mod, {:__block__, meta, exprs}) do
    process_exprs(mod, meta, exprs)
  end
  def monad_do_notation(mod, expr) do
    process_exprs(mod, [], [expr])
  end

  defp process_exprs(mod, meta, exprs) do
    x = {:__block__, meta, do_process_exprs(mod, exprs)}
    IO.puts(x |> Macro.to_string)
    x
  end

  defp do_process_exprs(mod, [{ :let, _, let_exprs } | exprs]) do
    if length(let_exprs) == 1 and is_list(hd(let_exprs)) do
      case Keyword.fetch(hd(let_exprs), :do) do
        :error     -> let_exprs ++ do_process_exprs(mod, exprs)
        { :ok, e } ->
          [ e | do_process_exprs(mod, exprs) ]
      end
    else
      let_exprs ++ do_process_exprs(mod, exprs)
    end
  end
  defp do_process_exprs(mod, [{ :<-, _, [lhs, rhs] } | exprs]) do
    # x <- m  ==>  bind(b, fn x -> ... end)
    do_process_bind(mod, lhs, rhs, exprs)
  end
  defp do_process_exprs(_, [ expr ]) do
    [expr]
  end
  defp do_process_exprs(mod, [ expr | exprs ]) do
    # m       ==>  bind(b, fn _ -> ... end)
    do_process_bind(mod, quote(do: _), expr, exprs)
  end
  defp do_process_exprs(_, []) do
    []
  end

  defp do_process_bind(mod, lhs, rhs, exprs) do
    [quote do
      unquote(mod).bind(unquote(rhs), fn unquote(lhs) -> unquote_splicing(do_process_exprs(mod, exprs)) end)
    end]
  end

  @type monad :: any

  @callback return(any) :: monad
  @callback bind(monad, (any -> monad)) :: monad
end
