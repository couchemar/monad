defmodule Monad do
  use Behaviour

  @moduledoc """
  Behaviour that provides monadic do-notation and pipe-notation.

  ## Usage

  To use do-notation you need a module that implements Monad's callbacks,
  i.e. the module needs to have `return/1`, `bind/2`.  This allows you to write
  stuff like:

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

  The term "monad" is used here fairly loosely to refer to the whole concept of
  monads. One way of looking at monads is as a kind of "programmable
  semicolon". Monads define what happens between the evaluation of the
  expressions. They control how and whether the results from one expression are
  passed to the next. For a better explanation of what monads are, look
  elsewhere, the internet is full of good (and not so good) monad tutorials.

  ## Do-notation

  The do-notation supported is pretty simple. Basically there are three rules to
  remember:

  1. Every "statement" (i.e. thing on it's own line or separated by `;`) has to
     return a monadic value unless it's a "let statement".

  2. To use the value "inside" a monadic value write "pattern <- action" where
     "pattern" is a normal Elixir pattern and "action" is some expression which
     returns a monadic value.

  3. To use ordinary Elixir code inside a do-notation block prefix it with
     `let`. For multiple expressions or those for which precedence rules cause
     annoyances you can use `let` with a do block.

  ## Monad laws

  `return/1` and `bind/2` need to obey a few rules (the so-called "monad laws")
  to avoid surprising the user. In the following equivalences `M` stands for
  your monad module, `a` for an arbitrary value, `m` for a monadic value and `f`
  and `g` for functions that given a value return a new monadic value.

  Equivalence means you can always substitute the left side for the right side
  and vice versa in an expression without changing the result or side-effects

  * `M.bind(M.return(m), f)`    <=> `f.(m)` ("left identity")
  * `M.bind(m, &M.return/1)`    <=> `m`     ("right identity")
  * `M.bind(m, f) |> M.bind(g)` <=> `m |> M.bind(fn y -> M.bind(f.(y), g))` ("associativity")

  ## Pipe support

  The `pl` macro supports monadic pipelines. For example:

      pl Error, (File.read("/tmp/foo")
                 |> Code.string_to_quoted(file: "/tmp/foo")
                 |> Macro.safe_term)

  If any of the terms returns `{:error, x}` that's the return value of the
  pipeline, if `{:ok, x}` is returned the `x` is passed to the next item.

  For a slightly nicer look this is also supported:

      pl Error do
        File.read("/tmp/foo")
        |> Code.string_to_quoted(file: "/tmp/foo")
        |> Macro.safe_term)
      end

  Under the hood pipe binding works by calling the `pipebind` function in a
  monad module. If you use `use Monad.Behaviour` one is automatically created
  (you can still override it though).

  The `pipebind` function receives the AST form of a value argument and a
  function. It has to return some AST that essentially does what bind does but
  with a function that's missing the first argument. See the example below.

  ## Defining a monad

  To define your own monad create a module and use `Monad.Behaviour`. This will
  mark the module as containing a monad behaviour and create an overridable
  default `pipebind` function (which calls `bind`). You'll need to define
  `return` and `bind` yourself.

  Here's an example that defines `return`, `bind` and `pipebind`:

      defmodule Monad.List do
        use Monad.Behaviour

        def return(x), do: [x]
        def bind(x, f), do: Enum.flat_map(x, f)
        def pipebind(x, fc) do
          quote Enum.flat_map(x,
            &unquote(Macro.pipe(quote do &1 end, fc)))
        end
      end
  """

  @doc """
  Make the `m` and `pl` macros available in your module.
  """
  defmacro __using__(_opts) do
    quote location: :keep do
      require Monad
      import Monad, only: [m: 2, pl: 2]
    end
  end

  @doc """
  Monad do-notation.

  See the `Monad` module documentation.
  """
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

  defmacro pl(mod, pipeline) when is_list(pipeline) do
    mod = Macro.expand(mod, __CALLER__)
    case pipeline[:do] do
      nil                         ->
        raise ArgumentError, message:
          "Monad.pl called with a list but it's not a keyword list with " <>
          "a 'do' key (i.e. not a passed do block)"
      { __block__, _, [expr] }    -> pl_expand(mod, expr)
      expr                        -> pl_expand(mod, expr)
    end
  end
  defmacro pl(mod, pipeline) do
    pl_expand(Macro.expand(mod, __CALLER__), pipeline)
  end

  defp pl_expand(mod, pipeline) do
    # Enum.reduce is a left fold
    Macro.unpipe(pipeline) |> Enum.reduce(&(mod.pipebind(&2, &1)))
  end
 
  @type monad :: any

  @doc """
  Put a value in the monad.
  """
  @callback return(any) :: monad

  @doc """
  Bind a value in the monad to the passed function which returns a new monadic
  value.
  """
  @callback bind(monad, (any -> monad)) :: monad

  @doc """
  Like bind/2 but works on ASTs and the second argument should be a function
  call where the first argument is missing.
  """
  @callback pipebind(Macro.t, Macro.t) :: Macro.t
end

defmodule Monad.Internal do
  # Internal helpers for the monad stuff.
  @moduledoc false

  @doc false
  def expand(mod, [{:let, _, let_exprs} | exprs]) do
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
  def expand(mod, [{:<-, _, [lhs, rhs]} | exprs]) do
    # x <- m ==> bind(b, fn x -> ... end)
    expand_bind(mod, lhs, rhs, exprs)
  end
  def expand(_, [expr]) do
    [expr]
  end
  def expand(mod, [expr | exprs]) do
    # m ==> bind(b, fn _ -> ... end)
    expand_bind(mod, quote(do: _), expr, exprs)
  end
  def expand(_, []) do
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
end

defmodule Monad.Behaviour do
  @moduledoc """
  Helper for defining a monad.

  Just `use Monad.Behaviour` in your monad module and define `return/1` and
  `bind/2` and you get `pipebind/2` for free.
  """
  defmacro __using__(_opts) do
    quote location: :keep do
      @behaviour Monad
      
      @doc """
      Monad do-notation.

      See the `Monad` module documentation and the
      """ <> "`#{inspect __MODULE__}`" <> """
      module documentation
      """
      defmacro m(do: block) do
        imp = quote do import unquote(__MODULE__), only: [return: 1] end
        case block do
          nil ->
            raise ArgumentError, message: "missing or empty do block"
          {:__block__, meta, exprs} ->
            {:__block__, meta, [imp|Monad.Internal.expand(__MODULE__, exprs)]}
          expr ->
            {:__block__, [], [imp|Monad.Internal.expand(__MODULE__, [expr])]}
        end
      end

      def pipebind(x, fc) do
        quote location: :keep do
          # I think there should be no conflict with the variable used in `fn`,
          # but just to be sure let's use an odd variable name.
          bind(unquote(x), fn _monad_pipebind_arg ->
            unquote(Macro.pipe(quote do _monad_pipebind_arg end, fc))
          end)
        end
      end

      defoverridable [pipebind: 2]
    end
  end
end
