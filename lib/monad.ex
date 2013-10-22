defmodule Monad do
  use Behaviour

  @moduledoc """
  Behaviour that provides monadic do-notation.

  ## Usage

  To use do-notation you need a module that implements Monad's
  callbacks, i.e. the module needs to have `return/1` and `bind/2`.
  This allows you to write stuff like:

      def call_if_safe_div(f, x, y) do
        use Monad
        import Monad.Maybe

        m Monad.Maybe do
          result <- case y == 0 do
                      true  -> fail "division by zero"
                      false -> return x / y
                    end
          return f.(result)
        end
      end

  ## Terminology

  The term "monad" is used here fairly loosely to refer to the whole
  concept of monads. One way of looking at monads is as a kind of
  "programmable semicolon". Monads define what happens between the
  evaluation of the expressions. They control how and whether the
  results from one expression are passed to the next. For a better
  explanation of what monads are, look elsewhere, the internet is full
  of good (and not so good) monad tutorials.

  ## Do-notation

  The do-notation supported is pretty simple. Basically there are
  three rules to remember:

  1. Every "statement" (i.e. thing on it's own line or separated by
     `;`) has to return a monadic value unless it's a "let statement".

  2. To use the value "inside" a monadic value write "pattern <-
     action" where "pattern" is a normal Elixir pattern and "action"
     is some expression which returns a monadic value.

  3. To use ordinary Elixir code inside a do-notation block prefix it
     with `let`. For multiple expressions or those for which
     precedence rules cause annoyances you can use `let` with a do
     block.

  ## Monad laws

  `return/1` and `bind/2` need to obey a few rules (the so-called
  "monad laws") to avoid surprising the user. In the following
  equivalences `M` stands for your monad module, `a` for an arbitrary
  value, `m` for a monadic value and `f` and `g` for functions that
  given a value return a new monadic value.

  Equivalence means you can always substitute the left side for the
  right side and vice versa in an expression without changing the
  result or side-effects

  * `M.bind(M.return(m), f)`    <=> `f.(m)` ("left identity")
  * `M.bind(m, &M.return/1)`    <=> `m`     ("right identity")
  * `M.bind(m, f) |> M.bind(g)` <=> `m |> M.bind(fn y -> M.bind(f.(y), g))` ("associativity")
  """

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
        {:ok, e} ->
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
