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
  js: (name: "mls")
))

#let bib = bytes(
  "@article{glenstrup2005termination,
  title     = {Termination analysis and specialization-point insertion in offline partial evaluation},
  author    = {Glenstrup, Arne John and Jones, Neil D},
  journal   = {ACM Transactions on Programming Languages and Systems (TOPLAS)},
  volume    = {27},
  number    = {6},
  pages     = {1147--1215},
  year      = {2005},
  publisher = {ACM New York, NY, USA},
  url       = {https://dl.acm.org/doi/pdf/10.1145/1108970.1108973},
  comment   = {Mentiones techniques to prove the termination of the generation process of partial evaluation}
}
@inproceedings{helsen2000fragmental,
  title       = {Fragmental specialization},
  author              = {Helsen, Simon and Thiemann, Peter},
  booktitle        = {International Workshop on Semantics, Applications, and Implementation of Program Generation},
  pages                = {51--71},
  year                  = {2000},
  organization  = {Springer},
  comment            = {Specialization accross compilation modules, may be useful for the Implementation section}
}
@misc{bruzzone2026metamonomorphizingspecializations,
  title   = {Meta-Monomorphizing Specializations}, 
  author={Federico Bruzzone and Walter Cazzola},
  year={2026},
  eprint={2602.12973},
  archivePrefix={arXiv},
  primaryClass={cs.PL},
  url={https://arxiv.org/abs/2602.12973}, 
}
@phdthesis{helsen2002region,
  title   = {Region-Based Program Specialization},
  author  = {Helsen, Simon},
  year    = {2002},
  school  = {Verlag nicht ermittelbar},
  comment = {Binding Time Analysis with polyvariance, an extension of Fragmental Compilation}
}
@article{helsen2004polymorphic,
  title     = {Polymorphic specialization for ML},
  author    = {Helsen, Simon and Thiemann, Peter},
  journal   = {ACM Transactions on Programming Languages and Systems (TOPLAS)},
  volume    = {26},
  number    = {4},
  pages     = {652--701},
  year      = {2004},
  publisher = {ACM New York, NY, USA},
  comment   = {Not particularly relevant, +ML +specialization -region valculus}
}
@inproceedings{kiselyov2017stream,
  title     = {Stream fusion, to completeness},
  author    = {Kiselyov, Oleg and Biboudis, Aggelos and Palladinos, Nick and Smaragdakis, Yannis},
  booktitle = {Proceedings of the 44th ACM SIGPLAN Symposium on Principles of Programming Languages},
  pages     = {285--299},
  year      = {2017},
  comment   = {Strymonas library for potential porting, +staging +ZCA}
}
@inproceedings{lionel2024diff,
  title     = {Diff-based interactive compiler debugging and testing},
  author    = {Luyu Cheng, Lionel Parreaux},
  booktitle = {Proceedings of the 44th ACM SIGPLAN Symposium on Principles of Programming Languages},
  pages     = {285--299},
  year      = {2017},
  comment   = {Strymonas library for potential porting, +staging +ZCA}
}
@article{lutze2025simple,
  title     = {The Simple Essence of Monomorphization},
  author    = {Lutze, Matthew and Schuster, Philipp and Brachth{\"a}user, Jonathan Immanuel},
  journal   = {Proceedings of the ACM on Programming Languages},
  volume    = {9},
  number    = {OOPSLA1},
  pages     = {1015--1041},
  year      = {2025},
  publisher = {ACM New York, NY, USA}
}
@inproceedings{parreaux2017quoted,
  title     = {Quoted staged rewriting: a practical approach to library-defined optimizations},
  author    = {Parreaux, Lionel and Shaikhha, Amir and Koch, Christoph E},
  booktitle = {Proceedings of the 16th ACM SIGPLAN International Conference on Generative Programming: Concepts and Experiences},
  pages     = {131--145},
  year      = {2017}
}
@inproceedings{parreaux2017squid,
  title     = {Squid: type-safe, hygienic, and reusable quasiquotes},
  author    = {Parreaux, Lionel and Shaikhha, Amir and Koch, Christoph E},
  booktitle = {Proceedings of the 8th ACM SIGPLAN International Symposium on Scala},
  pages     = {56--66},
  year      = {2017}
}
@inproceedings{parreaux2024seamless,
  author    = {Gao, Cunyuan and Parreaux, Lionel},
  title     = {Seamless Scope-Safe Metaprogramming through Polymorphic Subtype Inference (Short Paper)},
  year      = {2024},
  isbn      = {9798400712111},
  publisher = {Association for Computing Machinery},
  address   = {New York, NY, USA},
  url       = {https://doi.org/10.1145/3689484.3690733},
  doi       = {10.1145/3689484.3690733},
  abstract  = {Practical metaprogramming applications often involve manipulating open code fragments, which is easy to get wrong in the absence of static verification that all variable occurrences remain correctly bound. Many approaches have been proposed to verify the type- and scope-safety of metaprograms, but these approaches are either incomplete or cumbersome, imposing heavy type annotation or proof obligation burdens on metaprogrammers. In this short paper, we propose a new type system to statically keep track of the context requirements of code fragments. Our system uses a novel combination of Boolean-algebraic subtyping and first-class polymorphic type inference techniques to alleviate the annotation burden. The former provides the ability to encode scope requirements as unions of types and the latter allows these types to be locally quantified through a flexible form of polymorphic subtyping. We formalize this type system and demonstrate its implementation in the nascent MLscript functional and object-oriented programming language.},
  booktitle = {Proceedings of the 23rd ACM SIGPLAN International Conference on Generative Programming: Concepts and Experiences},
  pages     = {121–127},
  numpages  = {7},
  keywords  = {First-Class Polymorphism, Metaprogramming, Type Inference},
  location  = {Pasadena, CA, USA},
  series    = {GPCE '24}
}
@inproceedings{swadi2006monadic,
  title     = {A monadic approach for avoiding code duplication when staging memoized functions},
  author    = {Swadi, Kedar and Taha, Walid and Kiselyov, Oleg and Pasalic, Emir},
  booktitle = {Proceedings of the 2006 ACM SIGPLAN symposium on Partial evaluation and semantics-based program manipulation},
  pages     = {160--169},
  year      = {2006}
}
@inproceedings{taha2004gentle,
  title        = {A gentle introduction to multi-stage programming},
  author       = {Taha, Walid},
  booktitle    = {Domain-Specific Program Generation: International Seminar, Dagstuhl Castle, Germany, March 23-28, 2003. Revised Papers},
  pages        = {30--50},
  year         = {2004},
  organization = {Springer}
}",
)

// #show: themes.simple.simple-theme.with(
//   aspect-ratio: "16-9",
//   config-common(show-bibliography-as-footnote: bibliography(bib)),
// )


#title-slide()

#hide()

= Motivation

== Compile-Time vs. Run-Time Work

#slide[
  Programmers often write code in a clear, abstract style, even when parts of it could be computed during compilation.

  #columns(2)[
    *Original program*
    ```js
    fun dot(xs, ys) =
      if xs is
        Nil then 0
        Cons(x, xt) and ys is
          Cons(y, yt) then
            x * y + dot(xt, yt)

    fun dotWith3(v) =
      dot([1, 0, 2], v)
    ```

    #colbreak()

    *Residual program* (after specialising on `[1, 0, 2]`)
    ```js
    fun dotWith3(v) = v(0) + 2 * v(2)
    ```
  ]

  The recursion, the pattern matches, the multiplication by `0` — all known at compile time. The residual program contains only the work that genuinely depends on the runtime input `v`.

  #v(0.5em)
  #block(
    fill: luma(245), stroke: 0.5pt + luma(180), inset: 0.7em, radius: 4pt,
    width: 100%,
    [*Goal:* let the programmer keep the abstract version, and have the compiler peel away the static layer automatically.]
  )
]

== Multi-Stage Programming
Well-known optimization technique // (@taha2004gentle)

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
  Bar(x, y) then ...
```

Under single inheritance, matching arms runs into problems.

```js
class Foo$1$2 extends Bar
class Bar$2$3
```


= Overview

== MLscript Compiler

#align(center)[#image("pipeline-overview.svg", width: 95%)]

== Lowering Pass

We do instrumentation from Scala Block to Scala Block.
#align(center)[#image("pipeline-lowering.svg", width: 100%)]

== instrumentation

== Shape

We focus on tracking the shape of the values defined in Block, paths and results.

$ s ::= iota | bold("dyn") | [overline(s)] | C(overline(n\:s)) | bot | s union s $




= Implementation

== What's this for?

#slide[

  ```js
  staged module A with
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

For any Scala Block data, we can recreate the same structure with #strong([Staged Block]).
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

  The other Scala Block cases are similar, staging the parameters of the Scala Block by induction and recreating the corresponding Staged Block counterpart.
]

#slide[
  === Staging Symbols

  #alternatives[
  - We need more information about the Symbol in the original stage (particularly, tracking the previous stage values)

    Add redirection within current stage to allow access for next module

    // we might use import magic to import the module directly instead of using the module itself
    ```js
    staged class A with
      fun f() = M.f()
      val redirect_M = M
    ```
  ][
  - Uniqueness of Symbols
    
    We want Symbols for the same object in the previous stage to be unique in the current stage across functions and compilations

    For local functions, we can maintain a map during staging to reuse a staged symbol.
    
    For class and module symbols, we need to cache and use first instance of a symbol within the staged code.
  ]
]

== Shape Propagation

#let shape(s) = box[⟦#raw(s)⟧]

#slide[
  A *Shape* captures what we statically know about a value at compile time.

  $ s ::= iota | bold("dyn") | [overline(s)] | C(overline(n\:s)) | bot | s union s $

  We write #shape("s") to denote the shape of an expression, distinguishing it from actual values.

  #v(0.3em)
  ```js
  fun f(p, cond) =
    let a = 42                    // 42
    let b = C(p, 2)               // C(dyn, 2)
    let c = if cond
      then [1, 2, 3] else C(1,2)  // {[1,2,3], C(1,2)}
    let d = if b is C then 0 else 1 // 0
  ```

  Shapes are tracked in a context $Gamma$ mapping paths to their *ShapeSet*.
]

#slide[
  Before the formal rules, let's trace propagation on this module:

  ```js
  class C(val n)
  staged module If2 with
    fun f(x) =
      let y
      if x is C then  y = x.n
      else y = 0
      y + 1
    fun test()     = f(C(2))
    fun test2(dyn) = f(C(dyn))
    fun test3()    = f(0)
  ```
]

#let ctxbox(body) = block(
  fill: luma(245), stroke: 0.5pt + luma(180), inset: 0.6em, radius: 4pt,
  width: 100%, [#text(size: 0.8em, weight: "bold")[ctx] \ #body]
)

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
  module If2 with
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

Time: about 2x (from 2s to 1s, eh...)

Space: don't worry about it


/*

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
*/

// #magic.bibliography(title: none)