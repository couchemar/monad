# Monad

This library provides do-syntax and monads for
[Elixir](http://elixir-lang.org/). It is heavily inspired by
[Haskell](http://haskell.org/).

One way of looking at monads is as a kind of "programmable semicolon",
where the semicolon is used to separate multiple expressions. A monad
defines what happens between the evaluation of the expressions. It
controls how and whether the results from one expression are passed to
the next.

## Mechanics

The `m` macro provides do-syntax. Its expansion is quite
straightforward, though recursive.

### Base Case

A `m .. do` block consisting of a single expression expands to just
that expression. Consider the following example which involves the
`Maybe` monad:

    m Monad.Maybe do
      {:just, 42}
    end

Expands to:

    {:just, 42}

Note that a `pattern <- action` expression does not make sense as the
only (or last) expression in a `m ... do` block.

### Recursive Cases

Blocks consisting of more than one expression are expanded
recursively. There are two cases.

The first case is the expansion of `pattern <- action` expressions:

    m Monad.Maybe do
      pattern <- action
      ...
    end

Expands to:

    Monad.Maybe.bind(action, fn (pattern) -> ... end)

Where the body of the anonymous function is the expansion of the rest
of the expressions.

The second case is the expansion of all other kinds of expressions:

    m Monad.Maybe do
      action
      ...
    end

Expands to:

    Monad.Maybe.bind(action, fn (_) -> ... end)

Where the body of the anonymous function again is the expansion of the
rest of the expressions.
