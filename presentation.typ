#import "theme.typ": *
#import "code-style.typ": pc, cc, styling
// 1.3.1 fixes the nested highlighting, follow https://github.com/typst/packages to install a local version
#import "@local/codly:1.3.1": *
#import "@preview/codly-languages:0.1.10": *

#show: styling
#show: codly-init.with()

#show: university-theme.with(
  config-info(
    title: [Implementation and experimentation with Dynamic Staging],
    subtitle: [LP2],
    // lecture-number: 1,
    author: [CHING Long Tin, YEUNG Sin Chun],
    date: [2#super("nd") May 2026],
  ),
  header-right: none,
)

#codly(languages: (
  ..codly-languages,
  js: (name: "mls")
))

#hide()

#title-slide()

/* Checklist
1. First Class Transformer
2. Add Formalization to help explaining
3. Benchmarking
4. Merging the final to web-demo
5. Mention the inlining in mlscript for inlining functions to further improve the runtime (benchmark comparison is between inlining vs staging + inlining)
6. Host the web-demo on github page maybe
7. Mention the 'stub' thing
8. Research some more related works.
9. Explain the motivation why we recreate the Block data structure within MLScript instead of directly manipulating the Scala Block (Maintainability?)
*/

= Motivation

== Compile-Time vs. Run-Time Work

Programmers often write code in a clear, general style, even when parts of it could be computed during compilation.

#columns(2)[
  *Original program*
  ```js
  fun dot(xs, ys, i) =
    if xs.length == i then 0
    else xs.(i) * ys.(i)
      + dot(xs, ys, i + 1)

  fun dotWith3(v) =
    dot([1, 0, 2], v, 0)
  ```

  #colbreak()

  *can actually be written as*
  ```js
  fun dotWith3(v) = v(0) + 2 * v(2)
  ```
]

The recursion, the pattern matching, the multiplication are all known at compile time. The residual program contains only the work that genuinely depends on the runtime input `v`.

#v(0.5em)
#block(
  fill: luma(245), stroke: 0.5pt + luma(180), inset: 0.7em, radius: 4pt,
  width: 100%,
  [*Goal:* let the programmer keep the abstract version, and have the compiler peel away the static layer automatically.]
)

= Literature Survey

== Multi-Stage Programming
Well-known optimization technique @taha2004gentle

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

In here, green annotates code to be executed in the next stage, and gray executed in the current stage.


#slide[#local(number-format: none, lang-format: (_, _, _) => [], [
  Rule for ```js .!```: evaluate until we the whole code fragment is in the next stage, then move it to the current stage.
  #codly(highlights: (
    (line: 1, start: 4, end: 4, fill: green),
    (line: 1, start: 4, end: 4, fill: gray),
    (line: 1, start: 4, end: 4, fill: green),
    (line: 1, start: 11, end: 11, fill: green),
  ))
  ```js
  .! x = .! x = x
  ```

  During evaluation, we able to pre-compute certain parts of the code, reducing runtime.

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

Traditional Multi-Stage Programming tracks types.

Even if `x` has a known class shape, we cannot remove matching arms.

Specialization is done through typing, so we know that
`x : B`, but we do not know which specific derived class of `B` is used.

```js
data class Foo(x, y) extends Bar(x+1, y+1)

if new Foo(1, 2) is
  Bar(x, y) then ...
```

Under single inheritance, matching arms runs into problems. @shali2011hybrid

(Class splitting)
// https://www.cs.tufts.edu/comp/150FP/archive/william-cook/hybrid-partial-eval.pdf for second approach


```js
class Foo$1$2 extends Bar
class Bar$2$3
```
= Overview

== Approach in High Level

#slide[
  Start with an ordinary module:

  ```js
  module M with
    fun dot(xs, ys, i) =
      if xs.length == i then 0
      else xs.(i) * ys.(i) + dot(xs, ys, i + 1)
    fun dotWith3(v) = dot([1, 0, 2], v, 0)
  ```
]

#slide[
  Mark it as `staged`: the module now acts as a *code generator*:
  at compile time it specialises calls on known argument shapes and emits
  a residual module containing only the work that depends on runtime input.

  #codly(highlights: ((line: 1, start: 1, end: 6, fill: yellow),))
  ```js
  staged module M with
    fun dot(xs, ys, i) =
      if xs.length == i then 0
      else xs.(i) * ys.(i) + dot(xs, ys, i + 1)
    fun dotWith3(v) = dot([1, 0, 2], v, 0)
  ```
]

#slide[
  After staging,
  We are left with an ordinary (non-staged) module containing just
  the residual program that the user can use

  ```js
  module M with
    fun dotWith3(v) = v.(0) + 2 * v.(2)
    ... with more specialized functions ...
  ```

  Hence, our approach is a combination of *metaprogramming* (code generator) and *specialization* (generation of specialized functions).
]

== MLscript Compiler

#align(center)[#image("pipeline-overview.svg", width: 95%)]
- Lexer/Parser: converts source code into AST
- Elaborator/Resolver: Deal with references
- #strong[Lowering]: converts AST to a simplified format
- Codegen: Turn AST into executable code (JavaScript).

== Dynamic Staging Recipe

#align(center)[#image("pipeline-lowering.svg", width: 100%)]

Two phases: Instrumentation / Insert Optimizer

=== Lowering Pass

We implement staging a transformation from Scala Block $=>$ Scala Block.
// TODO

#slide[
  #align(center)[#image("pipeline-lowering-input.svg", width: 100%)]
  #align(center)[#block(width: 50%)[
  #text(size: 0.7em)[*Source (MLscript)*]
  #set text(size: 1em)
  #local(number-format: none,
  ```js
  if C(0) is
    Int  then "Int"
    C(n) then "C(" + n + ")"
    else "Unknown"
  ```)
  ]]
]

#slide[
  #align(center)[#image("pipeline-lowering-lowering.svg", width: 100%)]
  #align(center)[#block(width: 50%)[
  #text(size: 0.7em)[*Block*]
  #set text(size: 0.6em)
  #local(number-format: none,
  ```scala
  Scoped([scrut, n, arg, tmp],
    Assign(scrut, Call(C, [0])),
    Match(Ref(scrut), [
      Arm(Cls(Int), Ret("Int")),
      Arm(Cls(C),
        Assign(arg, Select(scrut, "n")),
        Assign(n,   Ref(arg)),
        Assign(tmp, Call("+", ["C(", n])),
        Ret(Call("+", [tmp, ")"]))
    ], Ret("Unknown")))
  ```)
  ]]
]

#slide[
  #align(center)[#image("pipeline-lowering-instrumentation.svg", width: 100%)]
  #align(center)[#block(width: 50%)[
  #text(size: 0.7em)[*Staged Block*]
  #set text(size: 0.6em)
  #local(number-format: none,
  ```js
  Scoped([scrut, n, arg, tmp],
    Assign(scrut, Call(C, [0])),
    Match(Ref(scrut), [
      Arm(Cls(Int), Ret("Int")),
      Arm(Cls(C),
        Assign(arg, Select(scrut, "n")),
        Assign(n,   Ref(arg)),
        Assign(tmp, Call("+", ["C(", n])),
        Ret(Call("+", [tmp, ")"]))
    ], Ret("Unknown")))
  ```)
  ]]
]

#slide[
  #align(center)[#image("pipeline-lowering-optimizer.svg", width: 100%)]
  #align(center)[#block(width: 50%)[
  #text(size: 0.7em)[*Opt(Staged Block)*]
  #set text(size: 0.5em)
  #local(number-format: none, highlights: ((line: 1, start: 1, end: 4, fill: yellow),),
  ```js
  prop(
    Scoped([scrut, n, arg, tmp],
      Assign(scrut, Call(C, [0])),
      Match(Ref(scrut), [
        Arm(Cls(Int), Ret("Int")),
        Arm(Cls(C),
          Assign(arg, Select(scrut, "n")),
          Assign(n,   Ref(arg)),
          Assign(tmp, Call("+", ["C(", n])),
          Ret(Call("+", [tmp, ")"]))
      ], Ret("Unknown")))
  )
  ```)
  ]]
]

#slide[
  #align(center)[#image("pipeline-lowering-printer.svg", width: 100%)]
  #align(center)[#block(width: 50%)[
  #text(size: 0.6em)[*Print(Opt(St. Blk))*]
  #set text(size: 0.5em)
  #local(number-format: none, highlights: ((line: 1, start: 1, end: 5, fill: yellow),),
  ```js
  print(
    prop(
      Scoped([scrut, n, arg, tmp],
        Assign(scrut, Call(C, [0])),
        Match(Ref(scrut), [
          Arm(Cls(Int), Ret("Int")),
          Arm(Cls(C),
            Assign(arg, Select(scrut, "n")),
            Assign(n,   Ref(arg)),
            Assign(tmp, Call("+", ["C(", n])),
            Ret(Call("+", [tmp, ")"]))
        ], Ret("Unknown")))
    )
  )
  ```)
  ]]
]

#slide[
  #align(center)[#image("pipeline-lowering-execute.svg", width: 100%)]
  #align(center)[#text(size: 0.8em)[*Compile & Execute*]]
  #text(size: 0.8em)[This execution is the *first stage* of metaprogramming. It entails the execution of 
  - the *optimizer* which outputs the *optimized staged block*, 
  - and the *printer* which prints the new MLscript program from the optimized staged block.]
]

#slide[
  #align(center)[#image("pipeline-lowering-output.svg", width: 100%)]
  #align(center)[#block(width: 50%)[
  #text(size: 0.7em)[*Generated MLscript*]
  #set text(size: 0.8em)
  #local(number-format: none, [
  ```js
  "C(0)"
  ```
  ])
  ]]
]



= Staging

== Staging Block

#slide[
```scala
case class Return(res, implct) extends Block
case class Match(scrut, arms, dflt, rest) extends Block
case class Assign(lhs, rhs, rest) extends Block
```

```js
class Block with
  constructor
    Return(res, implct)
    Match(scrut, arms, dflt, rest)
    Assign(lhs, rhs, rest)
```

For any Scala Block data, we can recreate the same structure within MLscript which we called #strong([Staged Block]).
]

#slide[
  ```js fun pow(x, n) = if n is 0 then 1 else x * pow(x, n-1) ```

  #text(0.8em)[

  #alternatives[
  ```scala
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

    #local(number-format: none, [
    ```js
    ValueLit(lit)
    ```
    ])

    Example: `1` $mapsto$ ```js ValueLit(1)```

    #colbreak()

    #alternatives[

    ```js Symbol(name)```
    #local(number-format: none, [
    ```js
    Symbol(name)
    ```
    ])

    Example:
    - `x` $mapsto$ ```js Symbol("x")```
    - `C` $mapsto$ ...?

    This is not enough for staging symbols. We'll revisit this case later on.
    ][
    ```js Value.Ref(sym)```

    #local(number-format: none, highlights: (
      (line: 1, start: 9, fill: blue),
    ), [
    ```js
    let l = sym
    ValueRef(l)
    ```
    ])
    
    Example: `x` $mapsto$ ```js ValueRef(Symbol("x"))```
    ]
  ]
  
  #only("2-")[
  ```js Select(qual, name)```

  #local(number-format: none, highlights: (
    (line: 1, start: 9, fill: blue),
    (line: 2, start: 9, fill: blue),
  ), [
  ```js
  let q = qual
  let n = name
  Select(q, n)
  ```
  ])
  
  Example: `x.p` $mapsto$ ```js Select(ValueRef(Symbol("x")), Symbol("p"))```
  ]
]

#slide[
  ```js Tuple([x0, x1, ...])```

  #local(number-format: none, skips: ((3, 1), ), highlights: (
    (line: 1, start: 10, fill: blue),
    (line: 2, start: 10, fill: blue),
  ), [
  ```js
  let s0 = x0
  let s1 = x1
  Tuple([x0, x1, ...])
  ```
  ])

  The other Scala Block cases are similar, staging the parameters of the Scala Block by induction and recreating the corresponding Staged Block counterpart.
]

== Staging Symbols

#alternatives-match((
  "1": [
  - We need more information about the Symbol in the original stage

    // for shape propagation
    Add reference to current value in the symbol
    
    ```js C.x```
    ```js
    let CSym = ClassSymbol("C", C)
    Select(ValueRef(CSym), Symbol("x"))
    ```

    Add redirection within current stage to allow access for next stage

    // we might use import magic to import the module directly instead of using the module itself
    ```js
    staged class A with
      fun f() = M.f()
      val redirect_M = M
    ```
  ],
  "2, 3": [
    - Uniqueness of Symbols

      We want Symbols for the same object in the previous stage to be unique in the current stage across functions and compilations.
  ],
  "2": [
    For local symbols, we can maintain a map during staging to reuse a staged symbol.

    ```js x + x```
    ```js
    let x = Symbol("x")
    // let x1 = Symbol("x")
    Call(ValueRef(Symbol("+")), [[ValueRef(x), ValueRef(x)]])
    ```
  ],
  "3": [
    For class and module symbols, we need to cache and use first instance of a symbol within the staged code.

    ```js M.f()```
    ```js
    let MSym = symbolMap.check(ModuleSymbol("M", M))
    Call(Select(ValueRef(MSym), Symbol("f")), [[]])
    ```
  ],
))

== Instrumentation

Insert some auxiliary helper variables/functions to the module for shape propagation.

```js
staged module Math with
  val funCache = new Map()
  val generatorMap = new Map([["pow", pow_gen]])
  fun pow_staged() = ...
  fun pow_gen(x, n) =
    specialize(funCache, "f", pow_staged, [x, n])
  fun propagate() = 
    let dyn = ...
    pow_gen(dyn, dyn)
    sq_gen(dyn)
```

#let shape(s) = box[⟦#raw(s)⟧]

#let ctxbox(body) = block(
  fill: luma(245), stroke: 0.5pt + luma(180), inset: 0.6em, radius: 4pt,
  width: 100%, [#text(size: 0.8em, weight: "bold")[ctx] \ #body]
)

= Shape Propagation

== Block and Shape

// rhs are all Results, parameters are all Paths
We focus on tracking the shape of the Paths and Results.

$ s ::= iota | bold("dyn") | [overline(s)] | C(overline(n\:s)) | bot | s union s $

```js
fun f(p, cond) =
  let a = 42
  let b = new C(p, 2)
  let c = if cond then [1, 2, 3] else C(1, 2)
  let d = if b is C then 0 else 1
```

#pagebreak()

=== Block in BNF 

#set text(size: 0.88em)
#let lbl(s) = text(style: "italic", fill: luma(110), size: 0.95em)[#s]

// Header rows: terminal categories paired side-by-side, like the paper.
#grid(
  columns: (1fr, 1fr),
  column-gutter: 1em,
  row-gutter: 0.85em,
  align: left + horizon,

  [#lbl[Symbol] #h(0.6em) $x, y, z$],
  [#lbl[Literal] #h(0.6em) $iota$],

  [#lbl[Function definition] #h(0.6em) $bold("fun") med f(overline(x_i)^n) = b$],
  [#lbl[Plain class definition] #h(0.6em) $bold("class") med C(overline(bold("val") med n))$],

  grid.cell(colspan: 2)[
    #lbl[Staged module definition] #h(0.6em) $bold("staged") med bold("module") med M med bold("with") med bold("fun") med f(overline(x_i)^n) = b$
  ],
)

#v(0.4em)

#grid(
  columns: (1fr, auto, auto, auto, 1fr),
  column-gutter: (0pt, 0.6em, 0.5em, 0pt),
  row-gutter: 0.85em,
  align: (right + horizon, right + horizon, center + horizon, left + horizon, left + horizon),

  [], lbl[Path], $p$,
    $::= iota | x | p.n$, [],
  [], lbl[Result], $r$,
    $::= p | f(overline(p)) | bold("new") med C(overline(p)) | [overline(p)]$, [],
  [], lbl[Match pattern], $pi$,
    $::= iota | C | \[\]^n | \_$, [],
  [], lbl[Match arm], $kappa$,
    $::= pi #h(0.4em) bold("then") #h(0.4em) b$, [],
  [], lbl[Non-tail block], $B$,
    $::= epsilon | bold("if") med p med bold("is") med overline(kappa); B | x = r; B | bold("let") med x; B$, [],
  [], lbl[Block], $b$,
    $::= bold("return") med r | bold("end") | B; med b$, [],
  [], lbl[Shape], $s$,
    $::= ⟦iota⟧ | bold("dyn") | ⟦[overline(s)]⟧ | ⟦C(overline(n\:s))⟧ | bot | s union s$, [],
  [], lbl[Shape context], $Gamma$,
    $::= epsilon | Gamma, p mapsto s quad (p eq.not x)$, [],
)

== A Tiny Example

#slide[
  A *Shape* captures what we statically know about a value at compile time.

  $ s ::= iota | bold("dyn") | [overline(s)] | C(overline(n\:s)) | bot | s union s $

  We write #shape("s") to denote the shape of an expression, distinguishing it from actual values.

  #v(0.3em)
  #grid(columns: (27em, 1fr), column-gutter: 1em, align: (left, left + horizon),
    [
      ```js
      fun f(p, cond) =
        let a = 42
        let b = C(p, 2)
        let c = if cond then [1, 2] else C(1, 2)
        let d = if b is C then 0 else 1
      ```
    ],
    [
      \
      #shape("42") \
      #shape("C(dyn, 2)") \
      #box[⟦#raw("[1,2]") $union$ #raw("C(1,2)")⟧] \
      #shape("0")
    ]
  )
]

#slide[
  === A First Taste

  A tiny program, propagating shapes by hand:

  ```js
  staged module M with
    fun add1(x) = x + 1
    fun test()  = add1(2)
  ```

  #v(0.4em)
  Walking through `test()`:

  + Argument `2` has shape #shape("2") (a literal).
  + Specialise `add1` with `x` ↦ #shape("2"); inside the body, `x` looks up #shape("2") in the context.
  + `x + 1` folds: #shape("2") `+` #shape("1") $arrow$ #shape("3").
  + Cache the result as `add1_Lit2() = 3`; rewrite the call site `add1(2)` to `add1_Lit2()`.

  #v(0.4em)
  Final shape of `test()`: #shape("3"). Body collapses to a constant.
]

== Shape Propagation (Formalization)
#slide[
  === Shape of Path ($Gamma tack.r p => s$)

  We evaluate paths $p$ to their shapes $s$.

  #let rule(name, premises, conclusion) = {
    set align(center)
    stack(dir: ttb, spacing: 0.6em,
      premises,
      box(stroke: (top: 0.6pt), inset: (top: 0.4em, x: 0.4em),
        conclusion,
      ),
    )
  }

  #let example(snippet, body) = block(
    stroke: (top: 0.4pt + luma(180)),
    inset: (top: 0.5em, x: 0.4em),
    width: 100%,
  )[
    #set align(left)
    #text(fill: luma(110), style: "italic")[Example] \
    #local(number-format: none, snippet)
    #body
  ]

  #v(1fr)
  #align(center)[
    #grid(columns: (1fr, 1fr, 1fr), column-gutter: 1.5em, row-gutter: 0.8em,
      align: (_, row) => if row == 0 { bottom + center } else { top + center },
      rule([Lit], $ $, $Gamma tack.r iota => ⟦iota⟧$),
      rule([Path], $(p mapsto s) in Gamma quad s eq.not bot$, $Gamma tack.r p => s$),
      rule([Sel], $p in.not "dom"(Gamma) quad Gamma tack.r p => s$, $Gamma tack.r p.n => "sel"(s, ⟦n⟧)$),
      example(```js
      42
      ```)[
        $Gamma = epsilon$ \
        $epsilon tack.r 42 => ⟦42⟧$
      ],
      example(```js
      x
      ```)[
        $Gamma = x mapsto ⟦C(n\:⟦1⟧)⟧$ \
        $Gamma tack.r x => ⟦C(n\:⟦1⟧)⟧$
      ],
      example(```js
      x.n
      ```)[
        $Gamma = x mapsto ⟦C(n\:⟦1⟧)⟧$ \
        $Gamma tack.r x.n => ⟦1⟧$
      ],
    )
  ]

  #v(1fr)
  #align(center)[
    #text(size: 0.9em, fill: luma(110))[
      $p ::= iota | x | p.n$
    ]
  ]
]

#slide[
  === Shape Selection (`sel`)

  $"sel"$ computes the shape of a selection.

  #v(1fr)
  $
    "sel"(⟦C(overline(n_i\:s_i))⟧, ⟦n_i⟧) &= s_i
      & quad "sel"(bold("dyn"), ⟦n_i⟧) &= bold("dyn") \
    "sel"(⟦[overline(s_i)^(i in 0..n)]⟧, ⟦i⟧) &= s_i
      & quad "sel"(s_1 union s_2, s) &= "sel"(s_1, s) union "sel"(s_2, s) \
    "sel"(s_1, s_2) &= bold("err") quad "otherwise"
  $

  #block(
    stroke: (top: 0.4pt + luma(180)),
    inset: (top: 0.5em, x: 0.4em),
    width: 100%,
  )[
    #set text(size: 1em)
    #text(fill: luma(110), style: "italic")[Example] \
    $
      "sel"(⟦[1,2]⟧ union ⟦[2,3,4]⟧, ⟦1⟧)
        &= "sel"(⟦[1,2]⟧, ⟦1⟧) union "sel"(⟦[2,3,4]⟧, ⟦1⟧) \
        &= ⟦2⟧ union ⟦3⟧
    $
  ]
  
  #v(1fr)
]

#slide[
  === Shape of Result (`sor`: $Gamma tack.r r ~> r' => s$)

  We optimize block and track shapes simultaneously: $r$ becomes $r'$ with shape $s$.

  #let rule(name, premises, conclusion) = {
    set align(center)
    stack(dir: ttb, spacing: 0.6em,
      premises,
      box(stroke: (top: 0.6pt), inset: (top: 0.4em, x: 0.4em),
        conclusion,
      ),
    )
  }

  #let example(snippet, body) = block(
    stroke: (top: 0.4pt + luma(180)),
    inset: (top: 0.5em, x: 0.4em),
    width: 100%,
  )[
    #set align(left)
    #text(fill: luma(110), style: "italic")[Example] \
    #local(number-format: none, snippet)
    #body
  ]

  #v(1fr)
  #align(center)[
    #set text(size: 0.8em)
    #grid(columns: (1fr, 1fr, 1fr), column-gutter: 0.8em, row-gutter: 0.9em,
      align: (_, row) => if row == 0 { bottom + center } else { top + center },
      rule([Path],
        $Gamma tack.r p => s$,
        $Gamma tack.r p ~> p => s$),
      rule([Tuple],
        $Gamma tack.r p_i => s_i$,
        $Gamma tack.r [overline(p_i)^n] ~> [overline(p_i)^n] => ⟦[overline(s_i)^n]⟧$),
      rule([New],
        $Gamma tack.r p_i => s_i$,
        $Gamma tack.r bold("new") med C(overline(p_i)) ~> bold("new") med C(overline(p_i)) => ⟦C(overline(n_i\:s_i))⟧$),
      example(```js
      x
      ```)[
        $Gamma = x mapsto ⟦1⟧$ \
        $Gamma tack.r x ~> x => ⟦1⟧$
      ],
      example(```js
      [x, y]
      ```)[
        $Gamma = x mapsto ⟦1⟧, y mapsto ⟦2⟧$ \
        $Gamma tack.r [x,y] ~> [x,y] => ⟦[⟦1⟧, ⟦2⟧]⟧$
      ],
      example(```js
      new Pair(x, y)
      ```)[
        $Gamma = x mapsto ⟦1⟧, y mapsto ⟦2⟧$ \
        $Gamma tack.r bold("new") med "Pair"(x,y) => ⟦"Pair"(a\:⟦1⟧, b\:⟦2⟧)⟧$
      ],
    )
  ]
  #v(1fr)
  #align(center)[
    #text(size: 0.9em, fill: luma(110))[
      $r ::= p | [overline(p)] | bold("new") med C(overline(p)) | f(overline(p))$
    ]
  ]
]

#slide[
  === Shape of Result (`sor`) — Staged Application

  #let rule(name, premises, conclusion) = {
    set align(center)
    stack(dir: ttb, spacing: 0.6em,
      premises,
      box(stroke: (top: 0.6pt), inset: (top: 0.4em, x: 0.4em),
        conclusion,
      ),
    )
  }

  When $f$ is *staged*, we recursively specialise its body on the argument shapes.

  #v(1fr)
  #align(center)[
    #set text(size: 0.95em)
    #stack(dir: ttb, spacing: 0.6em,
      $f " is staged" quad Gamma tack.r p_i => s_i quad f_"gen" thin (overline(p), overline(s)) = (r', s)$,
      box(stroke: (top: 0.6pt), inset: (top: 0.4em, x: 6em),
        $Gamma tack.r f(overline(p_i)) ~> r' => s$,
      ),
    )
  ]
  #v(0.8em)

  #block(
    stroke: (top: 0.4pt + luma(180)),
    inset: (top: 0.5em, x: 0.4em),
    width: 100%,
  )[
    #set text(size: 0.85em)
    #text(fill: luma(110), style: "italic")[Example] \
    #local(number-format: none,
      ```js
      staged module Staged with
        fun pyth(x, y) = x * x + y * y
        fun test() = pyth(2, 3)
      ```
    )
    Specialise $"pyth"_"gen" thin (⟦2⟧, ⟦3⟧)$ $arrow$ produces `pyth_Lit2_Lit3() = 13`, shape $⟦13⟧$. \
    Conclusion: $epsilon tack.r "pyth"(2,3) ~> 13 => ⟦13⟧$
  ]

  #v(1fr)
  #align(center)[
    #text(size: 0.9em, fill: luma(110))[
      $r ::= p | [overline(p)] | bold("new") med C(overline(p)) | f(overline(p))$
    ]
  ]
]

#slide[
  === Shape of Result (`sor`) — After Specialisation

  After propagation, the call site `pyth(2, 3)` is rewritten to its cached variant.

  #v(1fr)
  #align(center)[
    #set text(size: 0.95em)
    #stack(dir: ttb, spacing: 0.6em,
      $f " is staged" quad Gamma tack.r p_i => s_i quad f_"gen" thin (overline(p), overline(s)) = (r', s)$,
      box(stroke: (top: 0.6pt), inset: (top: 0.4em, x: 6em),
        $Gamma tack.r f(overline(p_i)) ~> r' => s$,
      ),
    )
  ]
  #v(0.8em)

  #block(
    stroke: (top: 0.4pt + luma(180)),
    inset: (top: 0.5em, x: 0.4em),
    width: 100%,
  )[
    #set text(size: 0.85em)
    #text(fill: luma(110), style: "italic")[Example] \
    #local(number-format: none,
      ```js
      staged module Staged with
        fun pyth_Lit2_Lit3() = 13
        fun test() = pyth_Lit2_Lit3()
      ```
    )
  ]

  #v(1fr)
  #align(center)[
    #text(size: 0.9em, fill: luma(110))[
      $r ::= p | [overline(p)] | bold("new") med C(overline(p)) | f(overline(p))$
    ]
  ]
]

=== Shape of Result (`sor`) — Non-Staged Application

#let rule(name, premises, conclusion) = {
  set align(center)
  stack(dir: ttb, spacing: 0.6em,
    premises,
    box(stroke: (top: 0.6pt), inset: (top: 0.4em, x: 4em),
      conclusion,
    ),
  )
}

When $f$ is *non-staged*, we don't have its Staged Block. Two sub-cases.

#v(1fr)
#align(center)[
  #set text(size: 0.78em)
  #grid(columns: (1fr, 1fr), column-gutter: 1.2em, row-gutter: 0.9em,
    align: (_, row) => if row == 0 { bottom + center } else { top + center },
    rule([StaticApp],
      stack(dir: ttb, spacing: 0.45em,
        $f " is non-staged" quad Gamma tack.r p_i => s_i quad forall i. med "static"(s_i)$,
        v(0.7em),
        $f_"imp" thin (overline("valOf"(s))) = (r, s)$,
      ),
      $Gamma tack.r f(overline(p_i)) ~> r => s$),
    rule([App-Dyn],
      $f " is non-staged" quad Gamma tack.r p_i => s_i quad exists i. med not "static"(s_i)$,
      $Gamma tack.r f(overline(p_i)) ~> f(overline(p_i)) => bold("dyn")$),
  )
]

#grid(columns: (1fr, 1fr), column-gutter: 1em,
  block(
    stroke: (top: 0.4pt + luma(180)),
    inset: (top: 0.5em, x: 0.4em),
    width: 100%,
  )[
    #set text(size: 0.78em)
    #text(fill: luma(110), style: "italic")[Example] \
    #local(number-format: none,
      ```js
      NonStaged.sq(2)
      ```
    )
    All args static; evaluate $"sq"(2) = 4$. \
    $epsilon tack.r "sq"(2) ~> 4 => ⟦4⟧$
  ],
  block(
    stroke: (top: 0.4pt + luma(180)),
    inset: (top: 0.5em, x: 0.4em),
    width: 100%,
  )[
    #set text(size: 0.78em)
    #text(fill: luma(110), style: "italic")[Example] \
    #local(number-format: none,
      ```js
      // where x is dynamic
      NonStaged.sq(x)
      ```
    )
    $Gamma = x mapsto bold("dyn")$; cannot evaluate, call remain unchanged. \
    $Gamma tack.r "sq"(x) ~> "sq"(x) => bold("dyn")$
  ],
)
#v(1fr)
#align(center)[
  #text(size: 0.9em, fill: luma(110))[
    $r ::= p | [overline(p)] | bold("new") med C(overline(p)) | f(overline(p))$
  ]
]

#pagebreak()

=== Non-Staged Application Example

#set text(size: 0.88em)
#columns(2)[
  #local(number-format: none,
    ```js
    module NonStaged with
      fun sq(x) = x * x

    staged module Staged with
      fun pyth(x, y) = NonStaged.sq(x) + NonStaged.sq(y)
      fun test() = pyth(2, 3)
    ```
  )

  #colbreak()

  #text(fill: luma(110), style: "italic")[After staging:]
  #v(0.3em)
  #local(number-format: none,
    ```js
    module Staged with
      fun pyth_Lit2_Lit3() = 13
      fun test() = 13
    ```
  )
]
- Since every params of ```js sq(x)``` is static, we will call `sq` to evaluate the result completely.

- No specialised functions are generated for the non-staged module `NonStaged`.

#v(1fr) 

#align(center)[
  #text(size: 0.9em, fill: luma(110))[
    $r ::= p | [overline(p)] | bold("new") med C(overline(p)) | f(overline(p))$
  ]
]

#pagebreak()

=== How do we call the function ```js sq```?

Recall that during execution of the optimizer, we already compile the function ```js NonStaged.sq(x)``` to JavaScript.

- Essentially we get the optimization for free in the static case (at no expense of code size)

#v(1fr)

#align(center)[#image("pipeline-lowering-execute.svg", width: 100%)]

#v(1fr)



#pagebreak()

=== Static Shape

#v(1fr)
#align(center)[
  #set text(size: 0.95em)
  $
    "static"(⟦iota⟧) &= bold("true") &quad
    "static"(⟦[overline(s_i)^n]⟧) &= and.big_i "static"(s_i) \
    "static"(⟦C(overline(n_i\:s_i))⟧) &= and.big_i "static"(s_i) &quad
    "static"(s_1 union s_2) &= "static"(s_1) and "static"(s_2) \
    "static"(bold("dyn")) &= bold("false") &quad
    "static"(bot) &= bold("false")
  $
]

#block(
  fill: luma(245), stroke: 0.5pt + luma(180),
  inset: 0.7em, radius: 4pt, width: 100%,
)[
  #text(weight: "bold")[Remark.] $"static"(s)$ returns true iff no subshape of $s$ contains $bold("dyn")$.
]

#v(1fr)

#align(center)[
  #text(size: 0.9em, fill: luma(110))[
    $r ::= p | [overline(p)] | bold("new") med C(overline(p)) | f(overline(p))$
  ]
]


== Shape Propagation (Pattern Matching)

#slide[
  Before giving the formal rules, let's give a simple trace of shape propagation for pattern matching.

  ```js
  class C(val n)
  staged module Simple with
    fun f(x) =
      let y
      if x is C then y = x.n
      else y = 0
      y + 1
    fun test()     = f(C(2))
    fun test2(dyn) = f(C(dyn))
    fun test3()    = f(0)
  ```
]

#slide[
  #columns(2)[
    === Trace 1: `test() = f(C(2))`

    Specialise `f` with `x` ↦ #shape("C(n: 2)").

    #only("2")[#codly(highlights: ((line: 2, start: 3, fill: yellow),))]
    #only("3")[#codly(highlights: ((line: 3, start: 3, fill: yellow),))]
    #only("4")[#codly(highlights: ((line: 4, start: 5, fill: yellow),))]
    #only("5")[#codly(highlights: ((line: 7, start: 3, fill: yellow),))]
    ```js
    fun f(x) =
      let y
      if x is C then
        y = x.n
      else
        y = 0
      y + 1
    ```

    #colbreak()

    #set text(size: 0.85em)
    #ctxbox[
      `x` ↦ #shape("C(n: 2)")
      #only("2-3")[\ `y` ↦ #shape("⊥")]
      #only("4-")[\ `y` ↦ #shape("2")]
    ]

    #pause
    + `let y`: extend ctx with `y` ↦ #shape("⊥")
    #pause
    + `if x is C`: `filter(`#shape("C(n: 2)")`, C)` = #shape("C(n: 2)") so `then` is viable; `rest` = #shape("⊥") so `else` is dead
    #pause
    + In `then`: `sop(x.n)` = `sel(`#shape("C(n: 2)")`, n)` = #shape("2"), so `y` ↦ #shape("2")
    #pause
    + `y + 1` folds to #shape("3"), then `Return 3`

    Cached as `f_C_Lit2`; body folds entirely to the constant `3`.
  ]
]

#slide[
  #columns(2)[
    === Trace 2: `test2(dyn) = f(C(dyn))`

    Argument shape: #shape("C(n: dyn)"). Specialise `f` with `x` ↦ #shape("C(n: dyn)").

    #only("2")[#codly(highlights: ((line: 2, start: 3, fill: yellow),))]
    #only("3")[#codly(highlights: ((line: 3, start: 3, fill: yellow),))]
    #only("4")[#codly(highlights: ((line: 4, start: 5, fill: yellow),))]
    #only("5")[#codly(highlights: ((line: 7, start: 3, fill: yellow),))]
    ```js
    fun f(x) =
      let y
      if x is C then
        y = x.n
      else
        y = 0
      y + 1
    ```

    #colbreak()

    #set text(size: 0.85em)
    #ctxbox[
      `x` ↦ #shape("C(n: dyn)")
      #only("2-3")[\ `y` ↦ #shape("⊥")]
      #only("4-")[\ `y` ↦ #shape("dyn")]
    ]

    #pause
    + `let y`: `y` ↦ #shape("⊥")
    #pause
    + `if x is C`: `filter(`#shape("C(n: dyn)")`, C)` = #shape("C(n: dyn)") so `then` is viable; `rest` = #shape("⊥") so `else` is dead
    #pause
    + In `then`: `sop(x.n)` = `sel(`#shape("C(n: dyn)")`, n)` = #shape("dyn")
    #pause
    + `y + 1`: cannot fold (#shape("dyn") `+ 1`); emit code, result #shape("dyn")

    Cached as `f_C_Dyn`; body keeps the `y = x.n` assignment.
  ]
]

#slide[
  #columns(2)[
    === Trace 3: `test3() = f(0)`

    Argument shape: #shape("0") (literal). Specialise `f` with `x` ↦ #shape("0").

    #only("2")[#codly(highlights: ((line: 2, start: 3, fill: yellow),))]
    #only("3")[#codly(highlights: ((line: 3, start: 3, fill: yellow),))]
    #only("4")[#codly(highlights: ((line: 6, start: 5, fill: yellow),))]
    #only("5")[#codly(highlights: ((line: 7, start: 3, fill: yellow),))]
    ```js
    fun f(x) =
      let y
      if x is C then
        y = x.n
      else
        y = 0
      y + 1
    ```

    #colbreak()

    #set text(size: 0.85em)
    #ctxbox[
      `x` ↦ #shape("0")
      #only("2-3")[\ `y` ↦ #shape("⊥")]
      #only("4-")[\ `y` ↦ #shape("0")]
    ]

    #pause
    + `let y`: `y` ↦ #shape("⊥")
    #pause
    + `if x is C`: `filter(`#shape("0")`, C)` = #shape("⊥") so `then` is dead; `rest(`#shape("0")`, C)` = #shape("0") so `else` is viable
    #pause
    + In `else`: `y` ↦ #shape("0")
    #pause
    + `y + 1` folds to #shape("1"), then `Return 1`

    Cached as `f_Lit0`.
  ]
]

#slide[
  === Resulting Cache

  After all three calls, the staged module contains:

  ```js
  module Simple withs
    fun f_C_Dyn(x) =
      let y
      y = x.n
      y + 1                 // dyn case: code is kept
    fun f_C_Lit2(x) = 3     // fully specialised
    fun f_Lit0()    = 1     // fully specialised
    fun test()      = 3
    fun test2(dyn)  = f_C_Dyn(C$If2(dyn))
    fun test3()     = 1
  ```
]

== Pattern Matching (Formalization)

#slide[
  === Branch Filter (`filter`)

  $"filter"$ removes impossible shapes from the branches of a pattern match.

  #set text(size: 0.85em)
  $
    "filter"(s, \_) &= s
      & quad "filter"(⟦iota_1⟧, iota_2) &= ⟦iota_1⟧ quad "if " iota_1 = iota_2 \
    "filter"(⟦[overline(s_i)^n]⟧, \[\]^n) &= ⟦[overline(s_i)^n]⟧
      & quad "filter"(⟦C(overline(n_i\:s_i)^m)⟧, C) &= ⟦C(overline(n_i\:s_i)^m)⟧ \
    "filter"(bold("dyn"), pi) &= "silh"(pi)
      & quad "filter"(s_1 union s_2, pi) &= "filter"(s_1, pi) union "filter"(s_2, pi) \
    "filter"(s, pi) &= bot quad "otherwise"
  $
]

#slide[
  === Branch Remainder (`rest`)

  $"rest"$ removes shapes already covered by a match pattern.

  #set text(size: 0.85em)
  $
    "rest"(s, \_) &= bot
      & quad "rest"(⟦iota_1⟧, iota_2) &= bot quad "if " iota_1 = iota_2 \
    "rest"(⟦[overline(s_i)^n]⟧, \[\]^n) &= bot
      & quad "rest"(⟦C(overline(n_i\:s_i)^m)⟧, C) &= bot \
    "rest"(bold("dyn"), pi) &= bold("dyn") quad "if " pi != \_
      & quad "rest"(s_1 union s_2, pi) &= "rest"(s_1, pi) union "rest"(s_2, pi) \
    "rest"(s, pi) &= s quad "otherwise"
  $
]

#slide[
  === Dynamic Dispatching
  When a method is called on a value with a *union shape*, we split by class and dispatch separately.

  #local(lang-format: (_, _, _) => [],
  ```js
  staged class B1(val y) with  fun call(x) = x + 2 + y
  staged class B2(val y) with  fun call(x) = x + y
  staged module M with
    fun twice(f, x) = f.call(f.call(x))
    fun pick(x, y, b) = if b then x else y
    fun f(b) =
      let m = pick(new B1(2), new B2(3), b)
      twice(m, 5)
  ```
  )
]

#slide[
  #columns(2)[
    === Trace A: `f(dyn)`


    Specialise `f` with `b` ↦ #shape("dyn").

    #only("2-")[#codly(highlights: ((line: 2, start: 3, fill: yellow),))]
    ```js
    fun f(b) =
      let m = pick(new B1(2), new B2(3), b)
      twice(m, 5)
    ```

    #colbreak()

    #set text(size: 0.85em)
    #ctxbox[
      `b` ↦ #shape("dyn")
      #only("2-")[\ `m` ↦ #shape("⊥")]
    ]

    #pause
    + `let m`: extend ctx with `m` ↦ #shape("⊥")
    #pause
    + Call `pick(new B1(2), new B2(3), b)`: argument shapes are #shape("B1(2)"), #shape("B2(3)"), #shape("dyn"). Recurse into `pick` with a fresh ctx $arrow$ *go to Trace B*
  ]
]

#slide[
  #columns(2)[
    === Trace B: `pick(B1(2), B2(3), dyn)`

    #only("2")[#codly(highlights: ((line: 1, start: 5, end: 17, fill: yellow),))]
    #only("3")[#codly(highlights: ((line: 2, start: 6, fill: yellow),))]
    #only("4")[#codly(highlights: ((line: 3, start: 3, fill: yellow),))]
    ```js
    fun pick(x, y, b) =
      if b then x
      else y
    ```

    #colbreak()

    #set text(size: 0.85em)
    #ctxbox[
      #text(size: 0.9em, style: "italic")[fresh ctx for `pick`] \
      `x` ↦ #shape("B1(2)") \
      `y` ↦ #shape("B2(3)") \
      `b` ↦ #shape("dyn")
    ]

    #pause
    + `if b`: `b` is #shape("dyn"), so both branches viable
    #pause
    + `then` arm returns `x`, shape = #shape("B1(2)")
    #pause
    + `else` arm returns `y`, shape = #shape("B2(3)")
    #pause
    + Result shape: #box[⟦#raw("B1(2)") $union$ #raw("B2(3)")⟧]. Cached as `pick1`. Return to Trace A.
  ]
]

#slide[
  #columns(2)[
    === Trace A (continued): back in `f`

    #only("1-2")[#codly(highlights: ((line: 2, start: 3, fill: yellow),))]
    #only("3-")[#codly(highlights: ((line: 3, start: 3, fill: yellow),))]
    ```js
    fun f(b) =
      let m = pick(new B1(2), new B2(3), b)
      twice(m, 5)
    ```

    #colbreak()

    #set text(size: 0.85em)
    #ctxbox[
      `b` ↦ #shape("dyn") \
      `m` ↦ #box[⟦#raw("B1(2)") $union$ #raw("B2(3)")⟧]
    ]

    #pause
    + Bind `m` to `pick`'s returned shape = #box[⟦#raw("B1(2)") $union$ #raw("B2(3)")⟧]
    #pause
    + `twice(m, 5)`: `m` has *union shape* $arrow$ *go to Trace C* and specialise as `twice1`
  ]
]

#slide[
  #columns(2)[
    === Trace C: `twice({B1(2), B2(3)}, 5)`

    #only("2")[#codly(highlights: ((line: 2, start: 3, fill: yellow),))]
    #only("3")[#codly(highlights: ((line: 3, start: 9, end: 18, fill: yellow),))]
    ```js
    fun twice(f, x) =
      let tmp
      tmp = f.call(x)
      f.call(tmp)
    ```

    Recall:
    ```js
    class B1(y) with 
      fun call(x) = x + 2 + y
    class B2(y) with 
      fun call(x) = x + y
    ```

    #colbreak()

    #set text(size: 0.85em)
    #ctxbox[
      `f` ↦ #box[⟦#raw("B1(2)") $union$ #raw("B2(3)")⟧] \
      `x` ↦ #shape("5")
      #only("2")[\ `tmp` ↦ #shape("⊥")]
      #only("3-")[\ `tmp` ↦ #shape("{9, 8}")]
    ]

    #pause
    + `let tmp`: extend ctx with `tmp` ↦ #shape("⊥")
    #pause
    + `f.call(x)` on union $arrow$ *split by class*:
      - `f` = #shape("B1(2)"): cache `f.call1()` $arrow$ #shape("9")
      - `f` = #shape("B2(3)"): cache `f.call1()` $arrow$ #shape("8")
  ]
]

#slide[
  #columns(2)[
    === Trace C (continued): second call

    #codly(highlights: ((line: 3, start: 3, end: 7, fill: yellow),))
    ```js
    fun twice(f, x) =
      let tmp
      tmp = f.call(x)
      f.call(tmp)
    ```

    Recall:
    ```js
    class B1(y) with fun call(x) = x + 2 + y
    class B2(y) with fun call(x) = x + y
    ```

    #colbreak()

    #set text(size: 0.85em)
    #ctxbox[
      `f` ↦ #box[⟦#raw("B1(2)") $union$ #raw("B2(3)")⟧] \
      `x` ↦ #shape("5") \
      `tmp` ↦ #shape("{9, 8}")
    ]

    #set enum(start: 3)
    + `f.call(tmp)` with `tmp` in #shape("{9, 8}") (now #shape("dyn")): split again, body kept as code
      - `f` = #shape("B1"): cache `f.call2(x) = x + 2 + 2`
      - `f` = #shape("B2"): cache `f.call2(x) = x + 3`
  ]
]

#slide[
  === Resulting Cache

  After propagation, `M` and the staged classes contain:

  #set text(size: 0.78em)
  #columns(2)[
    ```js
    module M with
      fun f(b) =
        let m, tmp1, tmp2
        tmp1 = new B1(2)
        tmp2 = new B2(3)
        m = pick1(tmp1, tmp2, b)
        twice1(m)
      fun pick1(x, y, b) =
        if b then new B1(2) else new B2(3)
    ```

    #colbreak()

    ```
      fun twice1(f) =
        let tmp
        if f is
          B1 then tmp = f.call1()
          B2 then tmp = f.call1()
        if f is
          B1 then f.call2(tmp)
          B2 then f.call2(tmp)
    ```

    #colbreak() 

    ```js
    class B1(y) with
      fun call1() = 9
      fun call2(x) =
        let tmp
        tmp = x + 2
        tmp + 2

    class B2(y) with
      fun call1() = 8
      fun call2(x) = x + 3
    ```
  ]
]

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

  ```js
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

// = Testing

// relevant? there's nothing really notable compared to ordinary MLscript development (diff/compile tests are already features within it)


= Benchmarking

== Model-View-Projection transformation

basically we're pretty good at partially evaluating matrices ^w^.

Time: about 2x (from 2s to 1s, eh...)

Code size: don't worry about it, we'll just do lifting


/*

  What happens when other staged modules want to access these private specialized functions? We just forbid specializing then.

  Those act as points that the user can call the staged module with. Other specialized functions are there too but they're mine. You can't touch them. I'm not even going to export them for you to access.

  for the per-block thing, saving the function calls until specialization?

  tracking shapes for Path and results

  refinement by pattern matching / selection


  // maybe we can introduce how each block is handled here

  Return/ValueRef: recall shape from current context

  Instantiate/Tuple: construct a new shape from current context

  (Dyn)Select/Match: refinement + remove dead branches

  Assign/Scoped/ValDefn: add the shape to ctx

  talk about tracking classes here, which addresses the class staging problems mentioned at the start.


  Call: oh boy... specialize if possible, then re-construct the shape

  - non-staged: evaluate if all static, otherwise
]

function calls: find the correct functions, for both staged and non-staged functions



== Specialization
how each individual function is called and specialized, combined with the caching

=== Entry functions

// What happens when other staged modules want to access these private functions?
Those act as points that the user can call the staged module with. Other specialized functions are there too but they're mine. You can't touch them. I'm not even going to export them for you to access.

#slide[
  === Example 1

  ```js
  staged module Math with
    fun pow(@dynamic x, n) = if n is
      0 then 1
      else x * pow(x, n-1)
    fun sq(x) = pow(x, 2)
  ```

  #codly(skips:((1,4),))
  ```js
    fun sq(x) = x * x * 1
  ```

  This example touches on shape tracking, match arm removal, and nested specialization.
]

*/

// #magic.bibliography(title: none)


#slide[#bibliography("ref.bib")]
