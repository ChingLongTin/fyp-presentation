#import "theme.typ": *
#import "code-style.typ": pc, cc, styling
// 1.3.1 fixes the nested highlighting, follow https://github.com/typst/packages to install a local version
#import "@local/codly:1.3.1": *
#import "@preview/codly-languages:0.1.10": *
#show: styling
#show: codly-init.with()

#show: university-theme.with(
  config-info(
    title: [Implementation and experimentation with program specialization and compilation techniques for writing high-performance programs],
    subtitle: [LP2],
    // lecture-number: 1,
    author: [CHING Long Tin, YEUNG Sin Chun],
    date: [2#super("nd") May 2026],
  ),
  header-right: none,
)
#codly(languages: (
  js: (name: "mls")
))


#title-slide()

= Motivation

== Multi-Stage Programming
Well-known optimization technique (ref here)

#codly(highlights: (
  (line: 2, start: 12, end: 12, fill: green),
  (line: 3, start: 10, end: 34, fill: green, inset: (top: 0em, bottom: 0em)),
  (line: 3, start: 12, end: 12, fill: gray),
  (line: 3, start: 19, end: 33, fill: gray),
  (line: 4, start: 20, end: 44, fill: green, inset: (top: 0em, bottom: 0em)),
  (line: 4, start: 28, end: 43, fill: gray, inset: (top: 0em, bottom: 0em)),
  (line: 4, start: 39, end: 39, fill: green),
))
#local(lang-format: (_, _, _) => [],
```js
fun power(n, x) = if n is
  0 then .<1>. 
  else .<.~x * .~(power(n - 1, x))>.
fun power2 = .! .<(x => .~(power(2, .<x>.)))>.
```
)

In here, green to annotates code to be executed in the next stage, and grey executed in the current stage.



#slide[#local(number-format: none, lang-format: (_, _, _) => [], [
  Rule for ```js .!```: evaluate until we turn the whole code fragment into the next stage, then move it to the current stage.
  #codly(highlights: (
    (line: 1, start: 4, end: 4, fill: green),
    (line: 1, start: 4, end: 4, fill: gray),
    (line: 1, start: 4, end: 4, fill: green),
    (line: 1, start: 11, end: 11, fill: green),
  ))
  ```js
  .! x = .! x = x
  ```

])
]

#slide[
  #codly(highlight-inset: (x: 0.3em, y: 2.5pt),
    highlights: (
    (line: 1, start: 0, fill: green),
    (line: 1, start: 6, fill: gray),
    (line: 1, start: 15, end: 15, fill: green),

    (line: 2, start: 0, fill: green),
    (line: 2, start: 6, fill: gray),
    (line: 2, start: 21, end: 21, fill: green),
    (line: 2, start: 28, fill: green),
    (line: 2, start: 28, end: 28, fill: green),
    (line: 2, start: 28, end: 28, fill: gray),
    (line: 2, start: 32, fill: gray),
    (line: 2, start: 45, end: 45, fill: green),

    (line: 3, start: 0, fill: green),
    (line: 3, start: 4 + 6, fill: gray),
    (line: 3, start: 4 + 15, end: 4 + 15, fill: green),

    (line: 4, start: 0, fill: green),
    (line: 4, start: 4 + 6, fill: gray),
    (line: 4, start: 4 + 21, end: 4 + 21, fill: green),
    (line: 4, start: 4 + 28, fill: green),
    (line: 4, start: 4 + 28, end: 4 + 28, fill: green),
    (line: 4, start: 4 + 28, end: 4 + 28, fill: gray),
    (line: 4, start: 4 + 32, fill: gray),
    (line: 4, start: 4 + 45, end: 4 + 45, fill: green),

    (line: 5, start: 0, fill: green),
    (line: 5, start: 8 + 6, fill: gray),
    (line: 5, start: 8 + 21, end: 8 + 21, fill: green),
    (line: 5, start: 8 + 28, fill: green),
    (line: 5, start: 8 + 28, end: 8 + 28, fill: green),
    (line: 5, start: 8 + 28, end: 8 + 28, fill: gray),
    (line: 5, start: 8 + 32, fill: gray),
    (line: 5, start: 8 + 45, end: 8 + 45, fill: green),

    (line: 6, fill: green)
  ))
  ```js
  x => power(2, x)
  x => if 2 is 0 then 1 else x * power(2 - 1, x)
  x => x * power(1, x)
  x => x * if 1 is 0 then 1 else x * power(1 - 1, x)
  x => x * x * if 0 is 0 then 1 else x * power(0 - 1, x)
  x => x * x * 1
  fun power2 = x => x * x * 1
  ```
]


== Class specialization

#columns(2)[
#local(lang-format: (_, _, _) => [],
```js
class B(val x) with
  fun f() = ...
// ...
if x is
  1 then new D1(1)
  2 then new D2(2)
  3 then new D3(3)

x.f()
```
)

#colbreak()

#codly(skips: ((1, 7), ))
```js
if x is
  D1 then x.D1_f1()
  D2 then x.D2_f1()
  D3 then x.D3_f1()
```
]

Even if `x` has a known class shape, we cannot remove matching arms.

Specialization is done through typing, so we know that
`x : B`, but we do not know which specific derived class of `B` is used.

```js
data class Foo(x, y) extends Bar(x+1, y+1)

if new Foo(1, 2) is
  Foo(x, y) then ...
```

Under single inheritance, matching arms runs into problems

```js
class Foo$1$2 extends Foo
class Bar$2$3
```


= Overview

== MLscript Compiler

The #emoji.sparkles Lowering #emoji.sparkles stage (boo i don't care that #emoji.sparkles has GenAI connotations)

== Lowering Pass

Term => Scala Block

We do instrumentation from Scala Block => Scala Block.


= Implementation

#slide[
```js
staged module A with
  fun pow(x, n) = if n is
    0 then 1
    else x * pow(x, n-1)
  fun sq(x) = pow(x, 2)
```

// check in with our result and see if it works
#codly(skips:((1,4),))
```js
  fun sq(x) = x * x * 1
```

This example touches on shape tracking, match arm removal, and nested specialization.
]

== Staging

#slide[
```Scala
case class Match(scrut, arms, dflt, rest) extends Block
case class Return(scrut, arms, dflt, rest) extends Block
case class Assign(lhs, rhs, rest) extends Block
```

```js
class Block with
  constructor
    Return(res, implct)
    Match(scrut, arms, dflt, rest)
    Assign(lhs, rhs, rest)
```

For any Scala Block data, we can recreate the same structure in Staged Block.
]

#slide[
  ```js fun pow(x, n) = if n is 0 then 1 else x * pow(x, n-1) ```

  #text(0.8em)[

  #alternatives[
  ```Scala
  val pow = Symbol("pow"); val x = Symbol("x"); val n = Symbol("n")
  val t1 = Symbol("tmp"); val t2 = Symbol("tmp")
  val sub = Symbol("-"); val mul = Symbol("*")
  FunDefn(pow, [x, n], Scoped(HashSet(t1, t2), Match(Ref(n),
    [[ Lit(0), Return(Lit(1)) ]],
    Assign(t1, Call(sub, [n, Lit(1)]), 
      Assign(t2, Call(pow, [x, t1]), 
        Return(Call(mul, [x, t2]))
      )
    ), End())
  ))
  ```][
    ```js
    let pow = Symbol("pow"); let x = Symbol("x"); let n = Symbol("n")
    let t1 = Symbol("tmp"); let t2 = Symbol("tmp")
    let sub = Symbol("-"); let mul = Symbol("*")
    FunDefn(pow, [x, n], Scoped([t1, t2], Match(Ref(n),
      [[ Lit(0), Return(Lit(1)) ]],
      Assign(t1, Call(sub, [n, Lit(1)]), 
        Assign(t2, Call(pow, [x, t1]), 
          Return(Call(mul, [x, t2]))
        )
      ), End())
    ))
    ```
  ]
  
  ]

  As long as we have the corresponding constructor, we can copy over the structure to the Staged Block.
]

// some simple base cases
#slide[
  We perform structural induction to stage each type of Scala Block.

  #columns(2)[
    ```js Value.Lit(lit)```

    ```js
    ValueLit(lit)
    ```

    Example: `1` $mapsto$ ```js ValueLit(1)```

    #colbreak()

    #alternatives[

    ```js Symbol(name)```
    ```js
    Symbol(name)
    ```

    Example:
    - `x` $mapsto$ ```js Symbol("x")```
    - `C` $mapsto$ ...?

    This is not enough for staging symbols. We'll revisit this case later on.
    ][
    ```js Value.Ref(sym)```

    #codly(highlights: (
      (line: 1, start: 9, fill: blue),
    )) 
    ```js
    let l = sym
    ValueRef(l)
    ```
    
    Example: `x` $mapsto$ ```js ValueRef(Symbol("x"))```
    ]
  ]
  
  #only("2-")[
  ```js Select(qual, name)```

  #codly(highlights: (
    (line: 1, start: 9, fill: blue),
    (line: 2, start: 9, fill: blue),
  ))
  ```js
  let q = qual
  let n = name
  Select(q, n)
  ```
  
  Example: `x.p` $mapsto$ ```js Select(ValueRef(Symbol("x")), Symbol("p"))```
  ]
]

// 
#slide[
  ```js Tuple([x0, x1, ...])```

  #codly(skips: ((3, 1), ), highlights: (
    (line: 1, start: 10, fill: blue),
    (line: 2, start: 10, fill: blue),
  ))
  ```js
  let s0 = x0
  let s1 = x1
  Tuple([x0, x1, ...])
  ```
]

#slide[
  === Staging Symbols

  - We need more information about the Symbol in the original stage (particularly, tracking the previous stage values)

    Add extra field to point to current stage's value

    Add redirection within current stage to allow access for next module
      
  - We want Symbols for the same object in the previous stage to be unique in the current stage across functions and compilations

    For local functions, we can maintain a map during staging to reuse a staged symbol.
    
    For class and module symbols, we need to cache and use first instance of a symbol within the staged code. 
]


#place(horizon + center, $mapsto$)

== Shape Propagation

=== Shape Definitions

$ s ::= underline(iota) | bold("dyn") | underline([overline(s)]) | underline(C)(overline(n\:s)) | bot | s union s $

for the per-block thing, saving the function calls until specialization?

`<shape definitions>`, tracking shapes

refinement by pattern matching / selection

function calls: find the correct functions, for both staged and non-staged functions



== Specialization
how each individual function is called and specialized, combined with the caching

=== Entry functions

// What happens when other staged modules want to access these private functions?
Those act as points that the user can call the staged module with. Other specialized functions are there too but they're mine. You can't touch them. I'm not even going to export them for you to access.



== Printing Staged Block

#slide[
  After all the specialized functions are completed, we need to write the functions to a new file.

  // FIXME: use the real example of power instead of an arbitrary module?
  ```js
  staged module M with
    val funCache = new Map([
      ["f1", ...],
      ["f2", ...],
      ["g1", ...]
    ])
  ```

  ```
  module M with
    fun f1(x, y) = ...
    fun f2() = ...
    fun g1() = ...
  ```
]

#slide[
  This is a similar process to staging, but done in reverse.

  As before, we need extra care when handling symbols.


]

= Testing

relevant? there's nothing really notable compared to ordinary mlscript development (diff/compile tests are already features within it)


= Benchmarking

== Model-View-Projection transformation

basically we're pretty good at partially evaluating matrices ^w^.