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
4. Mention the inlining in mlscript for inlining functions to further improve the runtime (benchmark comparison is between inlining vs staging + inlining)
5. Research some more related works.
*/

#let callout(name, text) = block(
    fill: luma(245), stroke: 0.5pt + luma(180), inset: 0.7em, radius: 4pt,
    width: 100%,
    [*$name$:* #text]
  )

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

  *... can actually be written as*
  ```js
  fun dotWith3(v) = v.(0) + 2 * v.(2)
  ```
]

The recursion, the pattern matching, the multiplication are all known at compile time. The residual program contains only the work that genuinely depends on the runtime input `v`.

#v(0.5em)
#callout([Goal], [
  let the programmer maintain the abstract version, and have the compiler automatically create a efficient implementation.
])

= Literature Survey

== Monomorphism

Specialised, efficient versions of a function are created from a template function.
```rs
use std::ops::Mul;
fn f<T: Mul<Output=T>>(x: T, y: T) -> T {
  x * y
}

fn main() {
  // uses built-in *
  f(1, 2);
  f(1.3, 4.5);
}
```

```rs
fn f1(x: i32, y: i32) -> i32 { x * y }
fn f2(x: f32, y: f32) -> f32 { x * y }

fn main() {
  // uses built-in *
  f1(1, 2);
  f2(1.3, 4.5);
}
```

#callout([Drawback], [
  We are unable to specialise a function on the specific values on the arguments.
])

Rust allows for constant generics, which is limited.
// because it's more programmer work

== Multi-Stage Programming

Well-known optimization technique, subfield of Partial Evaluation.

Example from @taha2004gentle:

#alternatives[
  #local(lang-format: (_, _, _) => [],
  ```js
  fun power(n, x) = if n is
    0 then 1 
    else x * power(n - 1, x)
  fun power2(x) = power(2, x)
  ```
  )
][
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
  
  Here, green annotates code to be executed in the next stage, and gray executed in the current stage.
]



#pagebreak()

#local(number-format: none, lang-format: (_, _, _) => [], [
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
])

Analogous to `eval`:

```py
eval("eval(\"1\")") = eval("1") = 1
```

During evaluation, we able to pre-compute certain parts of the code, reducing runtime.

#pagebreak()

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

#pagebreak()

#callout([Drawback],[
  The annotations need to be manually added, and so the library designer needs to anticipate uses of the library.
])
#v(0.5em)
#callout([Drawback],[
  Code fragments are evaluated separately, when the result of a code fragment may be reused.
])

#codly(highlights: (
  (line: 1, start: 21, end: 45, fill: green),
  (line: 1, start: 29, end: 44, fill: gray),
  (line: 1, start: 41, end: 41, fill: green),
))
```js
fun power10 = .! .<(x => .~(power(10, .<x>.)))>.
```

See memoization of code fragments in @swadi2006monadic.

// == Linking Rewriting DSLs

// // TODO
// Improve the compilation of functions with domain-specific modules. @parreaux2017quoted

== Hybrid Partial Evaluation @shali2011hybrid 

#columns(2)[
  #local(lang-format: (_, _, _) => [],
  ```js
  class D1(val x)
  class D2(val x)
  let y = if x is
    1 then new D1(1)
    2 then new D2(2)
  y.f()
  ```
  )

  #colbreak()
  #block(
    fill: luma(245), stroke: 0.5pt + luma(180), inset: 0.7em, radius: 4pt, width: 100%
  )[
    *Limitation:* Hybrid Partial Evaluation lacks *disjunctive class shapes* (e.g., #box[⟦#raw("D1(..)") $union$ #raw("D2(..)")⟧]), so `y.f()` cannot be specialized.
  ]
]

// == First Class Functions

// ```js

// ```

= Overview

== High-Level Approach

#pagebreak()

Start with an ordinary module:

```js
module M with
  fun dot(xs, ys, i) =
    if xs.length == i then 0
    else xs.(i) * ys.(i) + dot(xs, ys, i + 1)
  fun dotWith3(v) = dot([1, 0, 2], v, 0)
```

#pagebreak()

Users can mark a module as `staged` which turns the module into a *code generator*. When we execute the program, it emits a new residual module instead of executing the program.

#codly(highlights: ((line: 1, start: 1, end: 6, fill: yellow),))
```js
staged module M with
  fun dot(xs, ys, i) =
    if xs.length == i then 0
    else xs.(i) * ys.(i) + dot(xs, ys, i + 1)
  fun dotWith3(v) = dot([1, 0, 2], v, 0)
```


#pagebreak()

The output of executing the program is

```js
module M with
  fun dotWith3(v) = v.(0) + 2 * v.(2)
  // ... with more specialised functions ...
```

which the user can import.

Hence, our approach is a combination of *metaprogramming* (code generator) and *specialization* (generation of specialised functions).

== MLscript Compiler

MLscript Compiler is a compiler written in Scala that converts MLscript to JavaScript.

#align(center)[#image("pipeline-overview.svg", width: 95%)]
- Lexer/Parser: converts source code into AST
- Elaborator/Resolver: deal with references
- #strong[Lowering]: converts AST of *Term* to AST of *Block*
- Codegen: turn AST into executable code (JavaScript).

== Dynamic Staging Recipe

#align(center)[#image("pipeline-lowering.svg", width: 100%)]

Two phases: Instrumentation / Execute Optimizer

#pagebreak()

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


#pagebreak()

#align(center)[#image("pipeline-lowering-lowering.svg", width: 100%)]

#columns(2)[
#align(center)[
#text(size: 0.7em)[*Source (MLscript)*]
#set text(size: 1em)
#local(number-format: none,
```js
if C(0) is
  Int  then "Int"
  C(n) then "C(" + n + ")"
  else "Unknown"
```)
]
#colbreak()
#align(center)[#block()[
#text(size: 0.7em)[*Scala Block representation*]
#set text(size: 0.6em)
#local(number-format: none,
```scala
Scoped(Set(scrut, n, arg, tmp),
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

#pagebreak()

#align(center)[#image("pipeline-lowering-instrumentation.svg", width: 100%)]
#align(center)[#columns(2)[
#block()[
#set text(size: 0.7em)

*Staged Block*

#local(number-format: none,
```js
let b = Scoped([scrut, n, arg, tmp],
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
#colbreak()

*Scala Block representation*
#local(number-format: none,
```scala
Assign(Symbol("b"),
  Call("Scoped", [
    Tuple(Ref(Symbol("scrut")), ...),
    Assign(Symbol("tmp"), 
      Call("Assign", [Symbol("scrut")],
      ...
    )
  ]), ...
)
```)
]]]


#pagebreak()

#align(center)[#image("pipeline-lowering-optimizer.svg", width: 100%)]
#align(center)[#block(width: 50%)[
#text(size: 0.7em)[*Opt(Staged Block)*]
#local(number-format: none, highlights: ((line: 2, start: 1, end: 3, fill: yellow),),
```js
let b = ...
gen(b)
```)
]]

#pagebreak()

#align(center)[#image("pipeline-lowering-printer.svg", width: 100%)]
#align(center)[#block(width: 50%)[
#text(size: 0.6em)[*Print(Opt(Staged Block))*]
#local(number-format: none, highlights: ((line: 2, start: 1, end: 5, fill: yellow),),
```js
let b = ...
print(gen(b))
```)
]]

#pagebreak()

#align(center)[#image("pipeline-lowering-execute.svg", width: 100%)]
#align(center)[#text(size: 0.8em)[*Compile & Execute*]]
#text(size: 0.8em)[This execution is the *first stage* of metaprogramming. It entails the execution of 
- the *optimizer* which outputs the *optimized staged block*, 
- and the *printer* which prints the new MLscript program from the optimized staged block.]

#pagebreak()

#align(center)[#image("pipeline-lowering-output.svg", width: 100%)]
#align(center)[#block(width: 70%)[
#columns(2)[
  #text(size: 0.8em)[*Source MLscript*]
  #set text(size: 0.8em)
  #local(number-format: none,
  ```js
  if C(0) is
    Int  then "Int"
    C(n) then "C(" + n + ")"
    else "Unknown"
  ```)

  #colbreak()

  #text(size: 1em)[*Generated MLscript*]
  #set text(size: 0.8em)
  #local(number-format: none, [
  ```js
  "C(0)"
  ```
  ])
]
]]


= Staging

== Staging Block

#pagebreak()

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

Reduce the coupling of shape propagation logic to Scala Block.

// some simple base cases
#pagebreak()

As long as we have the corresponding constructor, we can copy over the structure to the Staged Block.

We perform structural induction to stage each type of Scala Block.

#columns(2)[
  ```js Value.Lit(true)```

  #local(number-format: none, [
  ```js
  ValueLit(true)
  ```
  ])

  #colbreak()

  #alternatives[

  ```js Symbol("x")```
  #local(number-format: none, [
  ```js
  Symbol("x")
  ```
  ])

  Example:
  - ```js ClassSymbol("C")``` $mapsto$ ...?

  This is not enough for staging symbols. We'll revisit this case later on.
  ][
  ```js Value.Ref(Symbol("x"))```

  #local(number-format: none, highlights: (
    (line: 1, start: 9, fill: blue),
  ), [
  ```js
  let l = Symbol("x")
  ValueRef(l)
  ```
  ])
  
  ]
]

#only("2-")[
```js Select(Value.Ref(Symbol("x")), Tree.Ident("p"))```

#local(number-format: none, highlights: (
  (line: 1, start: 9, fill: blue),
  (line: 2, start: 9, fill: blue),
), [
```js
let q = Value.Ref(Symbol("x"))
let n = Tree.Ident("p")
Select(q, n)
```
])
]


#pagebreak()

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


== Staging Symbols

#alternatives-match((
  "1": [
  - Keep track of current value in Staged Block

    // for shape propagation
    Add reference to current value in the symbol
    
    ```js Select(Value.Ref(ClassSymbol("C")), Tree.Ident("x"))```
    ```js 
    let CSym = ClassSymbol("C", C)
    Select(ValueRef(CSym), Symbol("x"))
    ```

    Add redirection within current stage to allow access for next stage

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

    ```js
    x + x
    ```
    ```js
    let x = Symbol("x")
    // let x1 = Symbol("x")
    Call(ValueRef(Symbol("+")), [[ValueRef(x), ValueRef(x)]])
    ```
  ],
  "3": [
    For class and module symbols, we need to cache and use first instance of a symbol within the current runtime.

    ```js M.f()```
    ```js
    let MSym = symbolMap.check(ModuleSymbol("M", M))
    Call(Select(ValueRef(MSym), Symbol("f")), [[]])
    ```
  ],
))

== Instrumentation

#focus-slide[A short demo on Instrumentation]

Insert some auxiliary helper variables/functions to the module for shape propagation.


#alternatives[
  ```js
  staged module Math with
    val funCache = new Map()
    val generatorMap = new Map([["pow", pow_gen]])
    fun pow_staged() = ...
    fun pow_gen(x, n) =
      specialise(funCache, "f", pow_staged, [x, n])
    fun propagate() = 
      let dyn = ...
      pow_gen(dyn, dyn)
      sq_gen(dyn)
  ```
][
  ```js
  staged module Math with
    val funCache // memoize specialised functions
    val generatorMap // point to generator function
    fun pow_staged() // return staged version of the function
    fun pow_gen(x, n) // redirect to shape propagation
    fun propagate() // generates all entry functions
  ```
]



#slide[
  For staged classes, we can treat the parameters of the class as the function parameter, then specialise the functions as usual.
  ```js
  staged class C(x, y) with
    fun add() = x + y
  ```
  ```js
  staged module C with
    fun add(cls)() = cls.x + cls.y
  ```
]

#let shape(s) = box[⟦#raw(s)⟧]

#let ctxbox(title: "ctx", body) = block(
  fill: luma(245), stroke: 0.5pt + luma(180), inset: 0.6em, radius: 4pt,
  width: 100%, [#text(size: 0.8em, weight: "bold")[#title] \ #body]
)

== Function-to-Class Transformation

Convert the lambda functions into classes, so that they can be uniformly treated as classes.

```js
fun f(y) = x => x + y

class Function(y) with
  fun call(x) = x + y
fun f(y) = Function(y)
```

= Shape Propagation

== Block in BNF 

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
  // [], lbl[Shape], $s$,
  //   $::= ⟦iota⟧ | bold("dyn") | ⟦[overline(s)]⟧ | ⟦C(overline(n\:s))⟧ | bot | s union s$, [],
  // [], lbl[Shape context], $Gamma$,
  //   $::= epsilon | Gamma, p mapsto s quad (p eq.not x)$, [],
)

== Block Example

#let hl(line, start, end: none, fill: yellow) = if end == none {
  (line: line, start: start, fill: fill)
} else {
  (line: line, start: start, end: end, fill: fill)
}

#grid(columns: (1fr, 1fr), column-gutter: 1.5em, align: (left, left + horizon),
[
  #only("2")[#codly(highlights: (
    hl(2, 11, end: 13),
    hl(3, 6, end: 6),
    hl(4, 12, end: 12),
    hl(4, 16, end: 16),
  ))]
  #only("3")[#codly(highlights: (
    hl(4, 12, end: 16, fill: aqua),
    hl(5, 10, end: 17, fill: aqua),
  ))]
  #only("4")[#codly(highlights: (
    hl(4, 5, end: 5, fill: green),
    hl(5, 5, end: 8, fill: green),
  ))]
  #only("5")[#codly(highlights: (
    hl(4, 5, end: 17, fill: orange),
    hl(5, 5, end: 18, fill: orange),
  ))]
  #only("6")[#codly(highlights: (
    hl(2, 3, end: 13, fill: rgb("#ffd1dc")),
  ))]
  #only("7")[#codly(highlights: (
  ))]
  ```js
  fun f(x) =
    let y = x.n
    if x is
      C then y + 1
      else new C(1)
  ```
],
[
  #only("2")[
    *Path* $p ::= iota | x | p.n$ \
    #text(size: 0.85em)[references like `x` and field accesses `x.n`]
  ]
  #only("3")[
    *Result* $r ::= p | f(overline(p)) | bold("new") med C(overline(p)) | [overline(p)]$ \
    #text(size: 0.85em)[a path, call, `new`, or tuple]
  ]
  #only("4")[
    *Match pattern* $pi ::= iota | C | \[\]^n | \_$ \
    #text(size: 0.85em)[here: `C` (class) and `_` (else)]
  ]
  #only("5")[
    *Match arm* $kappa ::= pi #h(0.3em) bold("then") #h(0.3em) b$ \
    #text(size: 0.85em)[a pattern paired with its body]
  ]
  #only("6")[
    *Non-tail block* $B ::= epsilon | bold("if") med p med bold("is") med overline(kappa); B | x = r; B | bold("let") med x; B$ \
    #text(size: 0.85em)[Two non-tailed block: assignment and pattern matching]
  ]
  #only("7")[
    *Block* $b ::= bold("return") med r | bold("end") | B; med b$ \
    #text(size: 0.85em)[There is an implicit End at this program since there is no return.]
  ]
]
)

== Shape Definition

#pagebreak()

A *Shape* captures what we statically know about a value at compile time.

$ #lbl[Shape] s ::= iota | bold("dyn") | [overline(s)] | C(overline(n\:s)) | bot | s union s $

We write #shape("s") to denote the shape of an expression, distinguishing it from actual values.

#v(0.3em)
#grid(columns: (23em, 1fr), column-gutter: 1em, align: (left, left + horizon),
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

The mechanism to calculate the shapes are called *Shape Propagation*.


#pagebreak()

=== A Tiny Example

```js
staged module M with
  fun add1(x) = x + 1
  fun test()  = add1(2)
```

Walking through `test()`:

+ Argument `x` has shape #shape("2")
+ Specialise `add1` with `x` ↦ #shape("2"); inside the body, `x` looks up #shape("2") in the context.
+ `x + 1` folds: #shape("2") `+` #shape("1") $arrow$ #shape("3").
+ Cache the result as `add1_Lit2() = 3`; rewrite the call site `add1(2)` to `add1_Lit2()`.

Final shape of `test()`: #shape("3"). Body collapses to a constant.

#pagebreak()

=== A Tiny Example (Residual Module)

The output residual module is generated with the specialized functions:

```js
module M with
  fun add1_Lit2() = 3
  fun test() = add1_Lit2()
```

Now, we begin to explain the mechanism of Shape Propagation, which is broken down into *Shape of Path*, *Shape of Result*, then *Shape of Block*.



== Shape of Path  ($Gamma tack.r p => s$)

We maintain a context $Gamma$ which tracks the shape of each path encountered so that we can evaluate the shape of every path.

#let rule(name, premises, conclusion) = {
  set text(size: 0.75em)
  set align(center)
  stack(dir: ttb, spacing: 0.6em,
    premises,
    box(stroke: (top: 0.6pt), inset: (top: 0.4em, x: 1.5em),
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
  #set text(size: 0.85em)
  #text(fill: luma(110), style: "italic")[Example] \
  #local(number-format: none, snippet)
  #body
]

#v(1fr)
#align(center)[
  #grid(columns: 3, column-gutter: 1.5em, row-gutter: 0.8em,
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
      $Gamma = x mapsto ⟦C(n\:1)⟧$ \
      $Gamma tack.r x => ⟦C(n\:1)⟧$
    ],
    example(```js
    x.n
    ```)[
      $Gamma = x mapsto ⟦C(n\:1)⟧$ \
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


#pagebreak()

=== Shape Selection (`sel`)

$"sel"$ computes the shape of a selection.

#v(1fr)
$
  "sel"(⟦C(overline(n_i\:s_i))⟧, ⟦n_i⟧) &= s_i
    & quad "sel"(bold("dyn"), ⟦n_i⟧) &= bold("dyn") \
  "sel"(⟦[overline(s_i)^(i in 0..n)]⟧, ⟦i⟧) &= s_i
    & quad "sel"(s_1 union s_2, s) &= "sel"(s_1, s) union "sel"(s_2, s) \
  "sel"(s_1, s_2) &= bold("err")
$

#block(
  stroke: (top: 0.4pt + luma(180)),
  inset: (top: 0.5em, x: 0.4em),
  width: 100%,
)[
  #set text(size: 1em)
  #text(fill: luma(110), style: "italic")[Example] \
  $
    "sel"(⟦1,2⟧ union ⟦2,3,4⟧, ⟦1⟧)
      &= "sel"(⟦1,2⟧, ⟦1⟧) union "sel"(⟦2,3,4⟧, ⟦1⟧) \
      &= ⟦2⟧ union ⟦3⟧
  $
]

#v(1fr)


#pagebreak()

== Shape of Result ($Gamma tack.r r ~> r' => s$)

We optimize block and track shapes simultaneously: $r$ becomes $r'$ with shape $s$.

#let rule(name, premises, conclusion) = {
  set text(size: 0.9em)
  set align(center)
  stack(dir: ttb, spacing: 0.6em,
    premises,
    box(stroke: (top: 0.6pt), inset: (top: 0.4em, x: 1.5em),
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
  #set text(size: 0.85em)
  #text(fill: luma(110), style: "italic")[Example] \
  #local(number-format: none, snippet)
  #body
]

#v(1fr)
#align(center)[
  #set text(size: 0.7em)
  #grid(columns: (0.7fr, 1.1fr, 1.5fr), column-gutter: 0.8em, row-gutter: 0.9em,
    align: (_, row) => if row == 0 { bottom + center } else { top + center },
    rule([Path],
      $Gamma tack.r p => s$,
      $Gamma tack.r p ~> p => s$),
    rule([Tuple],
      $Gamma tack.r p_i => s_i$,
      $Gamma tack.r [overline(p_i)^n] ~> [overline(p_i)^n] => ⟦overline(s_i)^n⟧$),
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
      $Gamma tack.r [x,y] ~> [x,y] => ⟦1, 2⟧$
    ],
    example(```js
    new Pair(x, y)
    ```)[
      $Gamma = x mapsto ⟦1⟧, y mapsto ⟦2⟧$ \
      $Gamma tack.r bold("new") med "Pair"(x,y) => ⟦"Pair"(a\:1, b\:2)⟧$
    ],
  )
]
#v(1fr)
#align(center)[
  #text(size: 0.9em, fill: luma(110))[
    $r ::= p | [overline(p)] | bold("new") med C(overline(p)) | f(overline(p))$
  ]
]

#pagebreak()

=== Shape of Result (`sor`) — Staged Application

#let rule(name, premises, conclusion) = {
  set text(size: 0.85em)
  set align(center)
  stack(dir: ttb, spacing: 0.6em,
    premises,
    box(stroke: (top: 0.6pt), inset: (top: 0.4em, x: 1.5em),
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
  Specialise $"pyth"_"gen" thin (⟦2⟧, ⟦3⟧)$ $arrow$ produces `pyth_Lit2_Lit3() = 13`, shape $⟦13⟧$. The $f_"gen"$ function will save the specialised function in a cache.\
  Conclusion: $epsilon tack.r "pyth"(2,3) ~> "pyth_Lit2_Lit3()" => ⟦13⟧$
]

#v(1fr)
#align(center)[
  #text(size: 0.9em, fill: luma(110))[
    $r ::= p | [overline(p)] | bold("new") med C(overline(p)) | f(overline(p))$
  ]
]


#pagebreak()

=== Shape of Result (`sor`) — Staged Application

After propagation, the call site `pyth(2, 3)` is rewritten to its cached variant.

#block[
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

#block[
  #set text(size: 0.8em)
  #text(fill: luma(110), style: "italic")[Cache] \
  #table(
    columns: (auto, auto, auto, auto, auto),
    stroke: 0.4pt + luma(180),
    inset: (x: 0.6em, y: 0.45em),
    fill: (_, row) => if row == 0 { luma(235) } else if row == 1 { yellow.lighten(60%) } else { white },
    [*Function*], [*Shapes*], [*Symbol*], [*Block*], [*Returned Shape*],
    [`pyth`], [$(⟦2⟧, ⟦3⟧)$], [`pyth_Lit2_Lit3`], [`return 13`], [$⟦13⟧$],
    [`pyth`], [$(bold("dyn"), bold("dyn"))$], [`pyth_Dyn_Dyn`], [`return x*x+y*y`], [$bold("dyn")$]
  )
  If $f_"gen"$ is called with the same $(f, overline(s))$ again, it looks up the existing entry in the cache instead of re-specialising.
]


#pagebreak()


=== Shape of Result (`sor`) — Non-Staged Application

#let rule(name, premises, conclusion) = {
  set text(size: 0.85em)
  set align(center)
  stack(dir: ttb, spacing: 0.6em,
    premises,
    box(stroke: (top: 0.6pt), inset: (top: 0.4em, x: 6em),
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

#columns(2)[
  #local(number-format: none,
    ```js
    module NonStaged with
      fun sq(x) = x * x

    staged module Staged with
      fun pyth(x, y) = 
        NonStaged.sq(x) 
        + NonStaged.sq(y)
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

- No specialised functions are generated for the non-staged module `NonStaged`.

#pagebreak()

=== How do we call the function ```js NonStaged.sq```?

Recall that during execution of the optimizer, we already compile the function `NonStaged.sq(x)` to JavaScript.

- Essentially we get the optimization for free in the static parameter case (at no expense of code size)

#v(1fr)

#align(center)[#image("pipeline-staging-only.svg", width: 100%)]

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
    "static"(bot) &= bold("err")
  $
]

#block(
  fill: luma(245), stroke: 0.5pt + luma(180),
  inset: 0.7em, radius: 4pt, width: 100%,
)[
  #text(weight: "bold")[Remark.] $"static"(s)$ returns true iff s is non-empty and no subshape of $s$ contains $bold("dyn")$.
]

#v(1fr)

#align(center)[
  #text(size: 0.9em, fill: luma(110))[
    $r ::= p | [overline(p)] | bold("new") med C(overline(p)) | f(overline(p))$
  ]
]

#pagebreak()

== Shape of Block (Pattern Matching)

=== Pattern Matching

For propagating on Block, the pattern matching Block is the most interesting. Let's dive in with an example.


#block(below: 0pt)[
  #set text(size: 0.85em)
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

#pagebreak()

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

#pagebreak()

#columns(2)[
  === Trace 2: `test2(dyn) = f(C(dyn))`

  Argument shape: #shape("C(n: dyn)"). Specialise `f` with `x` ↦ #shape("C(n: dyn)").

  #only("2")[#codly(highlights: ((line: 4, start: 5, fill: yellow),))]
  #only("3")[#codly(highlights: ((line: 7, start: 3, fill: yellow),))]
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

  #set text(size: 0.9em)
  #ctxbox[
    `x` ↦ #shape("C(n: dyn)")
    #only("1")[\ `y` ↦ #shape("⊥")]
    #only("2-")[\ `y` ↦ #shape("dyn")]
  ]

  Same opening as Trace 1 (`let y`, then `if x is C` keeps `then`, kills `else`). Continuing in `then`:

  #pause
  + In `then`: `sop(x.n)` = `sel(`#shape("C(n: dyn)")`, n)` = #shape("dyn")
  #pause
  + `y + 1`: cannot fold (#shape("dyn") `+ 1`); emit code, result #shape("dyn")

  Cached as `f_C_Dyn`; body keeps the `y = x.n` assignment.
]

#pagebreak()

#columns(2)[
  === Trace 3: `test3() = f(0)`

  Argument shape: #shape("0"). Specialise `f` with `x` ↦ #shape("0").

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

  #set text(size: 1em)
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

#pagebreak()

=== Resulting Cache

After all three calls, the staged module contains:

```js
module Simple with
  fun f_C_Lit2(x) = 3     // Trace A
  fun f_C_Dyn(x) =        // Trace B
    let y
    y = x.n
    y + 1
  fun f_Lit0()    = 1     // Trace C specialised
  fun test()      = 3
  fun test2(dyn)  = f_C_Dyn(C(dyn))
  fun test3()     = 1
```

== Pattern Matching (Formalization)

#pagebreak()

=== Branch Filter (`filter`)

#block(fill: luma(245), stroke: 0.5pt + luma(180), inset: 0.6em, radius: 4pt, width: 100%)[
  #set text(size: 0.9em)
  *Intuition.* $"filter"(s, pi)$ keeps the part of shape $s$ that *matches* the pattern $pi$ — i.e. the shape flowing into a branch.
]

#align(center)[
  #block[
    #set text(size: 0.75em)
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
]

#block(
  stroke: (top: 0.4pt + luma(180)),
  inset: (top: 0.5em, x: 0.4em),
  width: 100%,
)[
  #set text(size: 0.7em)
  #text(fill: luma(110), style: "italic")[Example] \
  $
    "filter"(⟦C(n\: bold("dyn"))⟧, C) &= ⟦C(n\: bold("dyn"))⟧ \
    "filter"(⟦0⟧, C) &= bot \
    "filter"(⟦C(n\: bold("dyn"))⟧ union ⟦0⟧, C)
      &= "filter"(⟦C(n\: bold("dyn"))⟧, C) union "filter"(⟦0⟧, C) \
      &= ⟦C(n\: bold("dyn"))⟧ union bot
      = ⟦C(n\: bold("dyn"))⟧
  $
]


#pagebreak()

=== Silhouette Function (`silh`)

$"silh"(pi)$ creates the shape of a pattern $pi$, with all sub-shapes set to $bold("dyn")$.

#align(center)[
  #block[
    #set text(size: 0.85em)
    $
      "silh"(iota) = ⟦iota⟧ quad
      "silh"(C) = ⟦C(overline(bold("dyn"))^n)⟧ quad
      "silh"(\[\]^n) = ⟦overline(bold("dyn"))^n⟧ quad
    $
  ]
]

#pagebreak()

=== Branch Remainder (`rest`)

#block(fill: luma(245), stroke: 0.5pt + luma(180), inset: 0.6em, radius: 4pt, width: 100%)[
  #set text(size: 0.9em)
  *Intuition.* $"rest"(s, pi)$ keeps the part of shape $s$ that does *not* match $pi$ — i.e. the shape flowing out of a branch
]

#block[
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

#block(
  stroke: (top: 0.4pt + luma(180)),
  inset: (top: 0.5em, x: 0.4em),
  width: 100%,
)[
  #set text(size: 1em)
  #text(fill: luma(110), style: "italic")[Example] \
  $
    "rest"(⟦C(n\: bold("dyn"))⟧ union ⟦0⟧, C)
      &= "rest"(⟦C(n\: bold("dyn"))⟧, C) union "rest"(⟦0⟧, C) \
      &= bot union ⟦0⟧ = ⟦0⟧
  $
]

#pagebreak()

=== Non Termination 1

Consider Fibonacci number:

```js
staged module Staged with
  fun fib(n) = if n is 
    1 then 1
    2 then 1
    n then fib(n - 1) + fib(n - 2)
```

With `n` ↦ #shape("dyn"), every branch is viable. The recursive call `fib(n - 1)` has argument shape #shape("dyn"), so shape propagation recurses forever, even though the original program terminates for valid inputs.



#pagebreak()

=== Solution: Stub Insertion

Before propagating into `fib(dyn)`, we *pre-insert a stub* into the cache:

#block[
  #set text(size: 0.8em)
  #text(fill: luma(110), style: "italic")[Cache (stub inserted)] \
  #v(0.3em)
  #table(
    columns: (auto, auto, auto, auto, auto),
    stroke: 0.4pt + luma(180),
    inset: (x: 0.6em, y: 0.45em),
    fill: (_, row) => if row == 0 { luma(235) } else if row == 1 { yellow.lighten(60%) } else { white },
    [*Function*], [*Shapes*], [*Symbol*], [*Block*], [*Returned Shape*],
    [`fib`], [$(bold("dyn"),)$], [`fib_Dyn`], [_stub_], [$bold("dyn")$],
  )
]

#v(0.5em)

Now when propagating the `fib(n - 1) + fib(n - 2)` arm:

+ `fib(n - 1)` has argument shape #shape("dyn") — matches the existing stub → rewritten to `fib_Dyn(n - 1)`.
+ `fib(n - 2)` likewise hits the stub → rewritten to `fib_Dyn(n - 2)`.
+ Result shape of the arm: #shape("dyn") `+` #shape("dyn") = #shape("dyn").

#pagebreak()
The completed specialised function will be

```js
fun fib_Dyn(n) = if n is
  1 then 1
  2 then 1
  n then fib_Dyn(n - 1) + fib_Dyn(n - 2)
```

#block[
  #set text(size: 0.8em)
  #text(fill: luma(110), style: "italic")[Cache (stub filled)] \
  #v(0.3em)
  #table(
    columns: (auto, auto, auto, auto, auto),
    stroke: 0.4pt + luma(180),
    inset: (x: 0.6em, y: 0.45em),
    fill: (_, row) => if row == 0 { luma(235) } else if row == 1 { yellow.lighten(60%) } else { white },
    [*Function*], [*Shapes*], [*Symbol*], [*Block*], [*Returned Shape*],
    [`fib`], [$(bold("dyn"),)$], [`fib_Dyn`], [`if n is ...`], [$bold("dyn")$],
  )
]

#block(
  fill: luma(245), stroke: 0.5pt + luma(180), inset: 0.7em, radius: 4pt, width: 100%,
)[
  #text(weight: "bold")[Remark.] Stub insertion only guarantees termination of shape propagation when *the original program terminates*. 
]

=== Non Termination 2

Consider a function that scans an array for a zero:

```js
staged module Staged with
  fun f(xs, i) =
    if xs.(i) is
      0 then i
      v then f(xs, i + 1)
```

With `xs` ↦ #shape("dyn") and `i` ↦ #shape("0") on the first call, `xs.(0)` is #shape("dyn") — both branches viable.

The recursive call has `i` ↦ #shape("1"), then #shape("2"), ... Shape Propagation diverges :(



#pagebreak()

=== Solution: Context Decay

Before processing the branches of `if xs.(i) is`, since the scrutinee has shape #shape("dyn"), we *decay* the context: every path that influenced the scrutinee is refined to #shape("dyn").

Here `xs.(i)` depends on `xs` and `i`, so both are decayed to #shape("dyn") before entering the branches.

#align(center)[
  #block[
    #set text(size: 0.85em)
    $
      "decay"(Gamma, p, s) &= Gamma quad "if " p != x "for some variable" x "or" s != bold("dyn") \
      "decay"(Gamma, x, bold("dyn")) &= attach(Gamma dot.op lr([overline(p_i mapsto bold("dyn"))]), tr: p_i in "alias"("clos"(x)))
    $
  ]
]

// #block(
//   fill: luma(245), stroke: 0.5pt + luma(180), inset: 0.7em, radius: 4pt, width: 100%,
// )[
//   #text(weight: "bold")[Remark.] $"clos"(x)$ is the set of paths whose values *flowed into* $x$ (i.e. arguments used to compute $x$). $"alias"(p)$ is the set of all paths that *point to the same value* as $p$ (e.g. if $x = "new" med C(y)$, then $y$ and $x.n$ are aliases). Together, $"alias"("clos"(x))$ collects every path in the context that could observe the dynamic value — all of which must be decayed to $bold("dyn")$.
// ]

With `i` ↦ #shape("dyn") after decay, `i + 1` ↦ #shape("dyn") too. The recursive call always hits a stable shape — propagation terminates.

#pagebreak()

Combining `filter`, `rest`, dead branch elimination and `decay` yields the following formalization for pattern matching.

#let rule(name, premises, conclusion) = {
  set text(size: 0.85em)
  set align(center)
  stack(dir: ttb, spacing: 0.6em,
    premises,
    box(width: 100%, stroke: (top: 0.6pt), inset: (top: 0.4em, x: 1.5em), conclusion),
  )
}

#v(1fr)
#align(center)[
  #set text(size: 0.78em)
  #rule([Match],
    grid(
      columns: 1, row-gutter: 1.2em, align: center,
      grid(
        columns: 2, column-gutter: 2.5em, align: center,
        $overline(Gamma_0 dot.op (p mapsto s_i') tack.r b_i ~> b_i' => Gamma_i\, s_i'')^(i=1..n\, s_i != bot)$,
        $Gamma_0 #sym.join overline(Gamma_i - Gamma_0)^(i=1..n\, s_i != bot) tack.r b_r ~> b_r' => Gamma'\, s$
      ),
      grid(
        columns: 3, column-gutter: 2.5em, align: center,
        $Gamma tack.r p => s_0$,
        $Gamma_0 = "decay"(Gamma, p, s_0)$,
        $overline(s_i' = "filter"(s_(i-1), pi_i) quad s_i = "rest"(s_(i-1), pi_i))^n$
      )
    ),
    $Gamma tack.r bold("if") med p med bold("is") med overline(pi_i med bold("then") med b_i)^n; med b_r ~> bold("if") med p med bold("is") med overline(pi_i med bold("then") med b_i')^(i=1..n\, s_i != bot); med b_r' => s$
  )
]
#v(1fr)



== Staged Class
Similar to staging module, we can stage classes as well, where we specialises on its method, with the main ingredient being how to handle dynamic dispatching `x.f()`

#block[
  #set text(size: 0.85em)
  #local(lang-format: (_, _, _) => [],
  ```js
  staged class B1(val y) with 
    fun call(x) = x + 2 + y
  staged class B2(val y) with 
    fun call(x) = x + y
  staged module M with
    fun twice(f, x) = f.call(f.call(x))
    fun pick(x, y, b) = if b then x else y
    fun f(b) =
      let m = pick(new B1(2), new B2(3), b)
      twice(m, 5)
  ```
  )
]



#pagebreak()

#columns(2)[
  === Trace A: `f(dyn)`

  #set text(size: 0.95em)
  Specialise `f` with `b` ↦ #shape("dyn").

  #only("2-")[#codly(highlights: ((line: 2, start: 3, fill: yellow),))]
  ```js
  fun f(b) =
    let m = pick(new B1(2),new B2(3),b)
    twice(m, 5)
  ```

  #colbreak()

  #ctxbox(title: [`f`'s ctx])[
    `b` ↦ #shape("dyn")
    #only("2-")[\ `m` ↦ #shape("⊥")]
  ]

  #pause
  + `let m`: extend ctx with `m` ↦ #shape("⊥")
  #pause
  + Call `pick(new B1(2), new B2(3), b)`: argument shapes are #shape("B1(2)"), #shape("B2(3)"), #shape("dyn"). Recurse into `pick` with a fresh ctx $arrow$ *go to Trace B*
]


#pagebreak()

#columns(2)[
  === Trace B: `pick(B1(2), B2(3), dyn)`

  #set text(size: 0.95em)
  #only("2")[#codly(highlights: ((line: 1, start: 5, end: 17, fill: yellow),))]
  #only("3")[#codly(highlights: ((line: 2, start: 6, fill: yellow),))]
  #only("4")[#codly(highlights: ((line: 3, start: 3, fill: yellow),))]
  ```js
  fun pick(x, y, b) =
    if b then x
    else y
  ```

  #colbreak()

  #ctxbox(title: [`pick`'s ctx])[
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


#pagebreak()

#columns(2)[
  === Trace A (continued): back in `f`

  #set text(size: 0.85em)
  #only("1-2")[#codly(highlights: ((line: 2, start: 3, fill: yellow),))]
  #only("3-")[#codly(highlights: ((line: 3, start: 3, fill: yellow),))]
  ```js
  fun f(b) =
    let m = pick(new B1(2), new B2(3), b)
    twice(m, 5)
  ```

  #colbreak()

  #ctxbox(title: [`f`'s ctx])[
    `b` ↦ #shape("dyn") \
    `m` ↦ #box[⟦#raw("B1(2)") $union$ #raw("B2(3)")⟧]
  ]

  #pause
  + Bind `m` to `pick`'s returned shape = #box[⟦#raw("B1(2)") $union$ #raw("B2(3)")⟧]
  #pause
  + `twice(m, 5)`: $arrow$ *go to Trace C* and specialise as `twice1`
]


#pagebreak()

#columns(2)[
  === Trace C: `twice({B1(2), B2(3)}, 5)`

  #only("2")[#codly(highlights: ((line: 2, start: 3, fill: yellow),))]
  #only("3")[#codly(highlights: ((line: 3, start: 9, end: 18, fill: yellow),))]
  #only("4-")[#codly(highlights: ((line: 3, start: 3, end: 7, fill: yellow),))]
  #[#set text(size: 0.85em)
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
  ```]

  #colbreak()

  #set text(size: 0.85em)
  #ctxbox(title: [`twice`'s ctx])[
    `f` ↦ #box[⟦#raw("B1(2)") $union$ #raw("B2(3)")⟧] \
    `x` ↦ #shape("5")
    #only("2-3")[\ `tmp` ↦ #shape("⊥")]
    #only("4-")[\ `tmp` ↦ #box[⟦#raw("9") $union$ #raw("8")⟧]]
  ]

  #only("2")[
    + `let tmp`: extend ctx with `tmp` ↦ #shape("⊥")
  ]
  #only("3")[
    #set enum(start: 2)
    + `f.call(x)` on union $arrow$ *split by class*:
      - `f` = #shape("B1(2)"):
        #ctxbox(title: [`B1.call`'s ctx])[
          `this` ↦ #shape("B1(2)") \
          `x` ↦ #shape("5")
        ]
        cache `f.call1()` in `B1` $arrow$ #shape("9")
      - `f` = #shape("B2(3)"): cache `f.call1()` in `B2` $arrow$ #shape("8")
    + Output a pattern matching $arrow$ ⟦#raw("9") $union$ #raw("8")⟧
  ]
  #only("4-")[
    #set enum(start: 4)
    + `tmp = f.call(x)`: bind `tmp` to #box[⟦#raw("9") $union$ #raw("8")⟧]
  ]
]


#pagebreak()

#columns(2)[
  === Trace C (continued): second call

  #codly(highlights: ((line: 4, start: 5, end: 15, fill: yellow),))
  #[#set text(size: 0.85em)
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
  ```]

  #colbreak()

  #set text(size: 0.85em)
  #ctxbox(title: [`twice`'s ctx])[
    `f` ↦ #box[⟦#raw("B1(2)") $union$ #raw("B2(3)")⟧] \
    `x` ↦ #shape("5") \
    `tmp` ↦ #box[⟦#raw("9") $union$ #raw("8")⟧]
  ]

  #set enum(start: 5)
  + `f.call(tmp)` with `tmp` in #box[⟦#raw("9") $union$ #raw("8")⟧]: split again, body kept as code
    - `f` = #shape("B1"): cache `f.call2(x) = x + 2 + 2` in `B1` $arrow$ #box[⟦#raw("13") $union$ #raw("12")⟧]
    - `f` = #shape("B2"): cache `f.call2(x) = x + 3` in `B2` $arrow$ #box[⟦#raw("12") $union$ #raw("11")⟧]
  + Output a pattern matching with a returned shape of ⟦#raw("13") $union$ #raw("12") $union$ #raw("11")⟧
]

#pagebreak()

=== Resulting Cache

After propagation, the residual `M` and the residual classes contain:

#grid(columns: (1fr, 1fr), column-gutter: 1.5em,
  [
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
  ],
  [
    #[
    #codly(offset: 9)
    ```js
    fun twice1(f) =
      let tmp
      if f is
        B1 then tmp = f.call1()
        B2 then tmp = f.call1()
      if f is
        B1 then f.call2(tmp)
        B2 then f.call2(tmp)
    ```
    ]
    
    #v(1em)
    #block(
      fill: luma(245), stroke: 0.5pt + luma(180), inset: 0.7em, radius: 4pt, width: 100%,
    )[
      #set text(size: 0.85em)
      #text(weight: "bold")[Remark.] If `f`'s shape included an *unstaged* class `B3`, we could not specialise the `B3.call` function without its Staged Block. The generated `twice1` would then include an `else` branch falling back to the original `f.call(...)`.
    ]
  ]
)

= Printing Staged Block

== Printing Staged Block

After all the specialised functions are completed, we need to write the functions to a new file.
This is a similar to staging, but done in reverse.

We do not export the specialised functions, in order to activate the inliner for the specialised functions.

#columns(2)[
  #set text(size: 0.9em)
  ```js
  staged module Math with
    val funCache = new Map([
      ["pow_Dyn_Lit1", Scoped(...)],
      ["pow_Dyn_Lit2", Scoped(...)],
      ["pow", Scoped(...)],
    ])
  ```

  #colbreak()

  #text(fill: luma(110), style: "italic")[Printed Output File:]
  ```js
  fun pow_Dyn_Lit1(x) = x
  fun pow_Dyn_Lit2(x) =
    let {tmp, tmp1}
    tmp = 1
    tmp1 = pow_Dyn_Lit1(x)
    *(x, tmp1)
  module Math with
    fun pow(x, n) = ...
  ```
]

= Inlining

== Inlining

A typical module after Dynamic Staging would look like the following:

#v(1em)

#columns(2)[
  #set text(size: 0.9em)
  *Dynamic Staging Output*
  ```js
  fun pow_Dyn_Lit1(x) =
    let {tmp, tmp1}
    x
  fun pow_Dyn_Lit2(x) =
    let {tmp, tmp1}
    tmp = 1
    tmp1 = pow_Dyn_Lit1(x)
    x * tmp1
  

  #[
    #codly(offset: 9)
      fun pow_Dyn_Lit3(x) =
      let {tmp, tmp1}
      tmp = 2
      tmp1 = pow_Dyn_Lit2(x)
      x * tmp1
  module M with
    fun pow(n, x) = ...
    fun cube(x) = ...
    ```
  ]


#pagebreak()

During *the second stage of compilation*, we utilize the MLscript compiler's existing inlining capabilities to inline function calls, as recursion has been eliminated during dynamic staging.

#align(center)[
  #set text(size: 0.75em)
  #align(left)[
    ```javascript
    let x, inlinedVal, tmp1, x1, inlinedVal1, tmp11, x2, inlinedVal2;
    x = 2;
    x1 = x;
    x2 = x1;
    inlinedVal2 = x2;
    tmp11 = inlinedVal2;
    inlinedVal1 = x1 * tmp11;
    tmp1 = inlinedVal1;
    inlinedVal = x * tmp1;
    return inlinedVal
    ```
  ]
]

= Benchmarking

== Model-View-Projection transformation

Applied in 3D rendering.


#box(width: 100%)[$ arrow(v) = M V P dot arrow(u) $]

#align(center)[#box(width: 60%)[
  #image("model_to_world_to_camera.png")
  (from opengl-tutorial)
]]


#pagebreak()

Evaluate matrix multiplications when the matrices are known values.

Benchmark: Transform 16k random coordinates using a known transformation matrices

#text(size: 0.85em, fill: luma(110))[Environment: MacBook Pro (13-inch, M1, 2020) with 16 GB RAM]

#v(1em)

#let bar(pct, color, label) = block(width: 100%, height: 1.4em, above: 0pt, below: 0pt)[
  #rect(width: pct, height: 100%, fill: color, radius: 2pt)
  #place(right, dy: -1.3em)[#box(inset: (x: 0.4em), text(weight: "bold", label))]
]

#columns(2)[
  === Time Taken (second)
  #v(0.5em)
  #grid(
    columns: (auto, 1fr),
    row-gutter: 1.2em,
    column-gutter: 0.8em,
    align: horizon,
    [*Original*], bar(100%, luma(220), [1.46]),
    [*Dynamic Staging*],  bar(38%, rgb("e08020"), [0.55]),
  )

  #colbreak()

  === Code Size (JS)
  #v(0.5em)
  #grid(
    columns: (auto, 1fr),
    row-gutter: 1.2em,
    column-gutter: 0.8em,
    align: horizon,
    [*Original*], bar(24.8%, luma(220), [242]),
    [*Dynamic Staging*],  bar(100%, rgb("e08020"), [975]),
  )
]

#pagebreak()
== Web-demo & QnA

#align(center)[
  #link("https://chinglongtin.github.io/mlscript/")
  #v(1em)
  #image("qrcode.png", width: 40%)
]

/*

  What happens when other staged modules want to access these private specialised functions? We just forbid specializing then.

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

#pagebreak()

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


*/

// #magic.bibliography(title: none)


#pagebreak()

#bibliography("ref.bib")
