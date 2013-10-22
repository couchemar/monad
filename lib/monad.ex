defmodule Monad do
  use Behaviour

  @doc """
  Make the `m` macro available in your module.
  """
  defmacro __using__(_opts) do
    quote location: :keep do
      require Monad
      import Monad, only: [m: 2]
    end
  end

  defmacro m(mod, do: block) do
    case block do
      nil ->
        raise ArgumentError, message: "missing or empty do block"
      {:__block__, meta, exprs} ->
        {:__block__, meta, expand(mod, exprs)}
      expr ->
        {:__block__, [], expand(mod, [expr])}
    end
  end

  defp expand(mod, [{:let, _, let_exprs} | exprs]) do
    if length(let_exprs) == 1 and is_list(hd(let_exprs)) do
      case Keyword.fetch(hd(let_exprs), :do) do
        :error ->
          let_exprs ++ expand(mod, exprs)
        { :ok, e } ->
          [e | expand(mod, exprs)]
      end
    else
      let_exprs ++ expand(mod, exprs)
    end
  end
  defp expand(mod, [{:<-, _, [lhs, rhs]} | exprs]) do
    # x <- m ==> bind(b, fn x -> ... end)
    expand_bind(mod, lhs, rhs, exprs)
  end
  defp expand(_, [expr]) do
    [expr]
  end
  defp expand(mod, [expr | exprs]) do
    # m ==> bind(b, fn _ -> ... end)
    expand_bind(mod, quote(do: _), expr, exprs)
  end
  defp expand(_, []) do
    []
  end

  defp expand_bind(mod, lhs, rhs, exprs) do
    [quote do
      unquote(mod).bind(unquote(rhs),
                        fn unquote(lhs) ->
                             unquote_splicing(expand(mod, exprs))
                        end)
    end]
  end

  @type monad :: any

  @callback return(any) :: monad
  @callback bind(monad, (any -> monad)) :: monad
end
