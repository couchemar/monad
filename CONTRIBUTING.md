# Contributing guidelines

Just send in a pull request.

TODO: Elaborate on this.

## Coding style

* Golden rule: just follow the style of the rest of the code.
* Avoid unneccesary whitespace in expressions with braces and brackets (tuples /
  lists). Don't write `{ :ok, a }`, write `{:ok, a}`. Whitespace is allowed
  in nested expressions if it significantly improves readability, but if things
  get that complicated prefer to rewrite the expression to be simpler (one spot
  where that's not always possible is pattern matching).
* Add documentation to all modules (`@moduledoc`) and public functions/macro's
  (`@doc`). Exception: implementations of callbacks don't need (but may have)
  documentation, if you leave off the documentation a default will be provided
  by the documentation generator.
* In documentation use the first line as a short summary, this will show up in
  the function/module/whatever overview in the documentation.
* Line length: limit the numbers of characters per line to 78.
