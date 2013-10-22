# Monad

This library provides do-syntax and monads for
[Elixir](http://elixir-lang.org/). It is heavily inspired by
[Haskell](http://haskell.org/).

One way of looking at monads is as a kind of "programmable semicolon",
where the semicolon is used to separate multiple expressions. A monad
defines what happens between the evaluation of the expressions. It
controls how and whether the results from one expression are passed to
the next.
