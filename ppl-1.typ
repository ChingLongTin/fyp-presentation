#import "theme.typ": *
#import "code-style.typ": pc, cc, styling
#show: styling

#show: university-theme.with(
  config-info(
    title: [Principles of Programming Languages],
    subtitle: [COMP 3031],
    lecture-number: 1,
    author: [Lionel Parreaux],
    date: "Fall 2025",
  ),
  header-right: none,
)

#title-slide()

/**** Principles of Programming Languages ****/

= Principles of Programming Languages

== Principles of Programming Languages

=== Instructor
Lionel Parreaux #raw("(parreaux@ust.hk)")

=== Teaching Assistants
- Yijia CHEN #raw("(ychenfo@connect.ust.hk)")
- Heung Tung AU #raw("(htauac@connect.ust.hk)")

#v(1em)
#align(center)[#line(length: 50%)]

_The materials in this course were largely adapted from similar EPFL courses by Martin Odersky and Viktor Kuncak, most notably CS-210._

== What is This Course About?
_A tour of important programming language paradigms and constructs,  
with an emphasis on functional programming and Scala._

=== Goals of the Course (ambitiously)
To _expand your mind_
and give you *new tools* enabling you
to solve *hard problems* in *easier and better* ways.

=== Expected Learning Outcomes
Become better at modeling problems and using
the right programming tools to solve them,
using powerful programming language concepts.

== Organization of the Course (1)

=== Lectures (L1)
Tuesday & Thursday, 12:00-13:20. \
Rm G009B, CYT Bldg

=== Labs (LA1)
Mondays, 15:00-16:20 \
_(Alternates between computer labs and pen & paper sessions.)_ \
Rm 4214 \

=== Office Hours
Up to 40 min after the lectures. \
Rm 3547

=== Midterm Exam
mid October *(TENTATIVE)*

== Organization of the Course (2)

=== Assignments
There will be three programming assignments. (Details to be given later.)

=== Exams
There will be a midterm exam and a final exam. 
// Both exams will be open-book.
The final exam will cover all course material, with emphasis on post-midterm topics. \

/*
Past midterm exams: Fall 2016 and solution  Download solution, Fall 2015 and solution  Download solution,  and Fall 2017 and solution  Download solution.

Past final exams and solutions: Fall 2017 exam and solution, Fall 2016 exam and solution, Fall 2015 exam and solution. */
We will give you some material to prepare.

=== Grading
Each assignments counts for 10%; the midterm 30%; and the final 40%.

All assignments should be done independently by individual students. You can discuss among peers, but the hand-ins should be your own work.

/*  Plagiarism or assistance to plagiarism will be dealt with following university policy. */

No late hand-ins will be accepted.

/* Skipping the midterm or final exam without prior approval or proper documentation (e.g., doctor's certificate for sickness on the exam day) results in a failing grade automatically. */

//  *Tentative* Syllabus =====================

== Programming Paradigms

Paradigm: In science, a _#pc[paradigm]_ describes distinct concepts or
thought patterns in some scientific discipline.

Main _#pc[programming]_ paradigms:
- imperative

== Programming Paradigms

Paradigm: In science, a _#pc[paradigm]_ describes distinct concepts or
thought patterns in some scientific discipline.

Main _#pc[programming]_ paradigms:
- imperative
- functional
- logic
- object-oriented
- concurrent
- parallel
- dependently-typed
- etc.

== Review: Imperative Programming

Imperative programming is about

- modifying mutable variables and memory locations using assignments
- control structures such as if-then-else, loops, break, continue, return

The most common informal way to understand imperative programs is as instruction sequences for a von Neumann computer.

== Imperative Programs and Computers

There's a strong correspondence between

#table(
  columns: (auto, auto, auto),
  stroke: none,
  inset: 8pt,
  fill: (_, y) => if calc.even(y) { white.darken(10%) },
  [Variables],[≈],[registers],
  [Mutable fields],[≈],[memory cells],
  [Variable dereferences],[≈],[load instructions],
  [Variable assignments],[≈],[store instructions],
  [Control structures],[≈],[jumps]
)

#v(1em)

*#pc[Problem]*: Scaling up. How can we avoid conceptualizing programs word by word?

*#pc[Reference]*: John Backus, Can Programming Be Liberated from the von. Neumann Style?, Turing Award Lecture 1978.

== Scaling Up

In the end, pure imperative programming is limited by the "von Neumann" bottleneck.
#align(center)[
  #text(style: "italic")[
    One tends to conceptualize data structures word-by-word.
  ]
]

We need other techniques for defining high-level abstractions such as collections, polynomials, geometric shapes, strings, documents.

Ideally: Develop _theories_ of collections, shapes, strings, ...

== What is a Theory?

A theory consists of

- one or more _#pc[data types]_
- _#pc[operations]_ on these types
- _#pc[laws]_ that describe the relationships between values and operations

Normally, a theory does not describe mutations!

== Theories without Mutation

For instance the theory of polynomials defines the sum of two polynomials by laws such as:

$ (a*x + b) + (c*x + d) = (a + c)*x + (b + d) $

But it does not define an operator to change a coefficient while keeping the polynomial the same!

#v(0.5em)
Whereas in an imperative program one *can* write:

```java
  class Polynomial { double[] coefficient; }
  Polynomial p = ...;
  p.coefficient[0] = 42;
```

== Theories without Mutation
*Other example:*

The theory of strings defines a concatenation operator ++ which is associative:

```
  (a ++ b) ++ c  =  a ++ (b ++ c)
```

But it does not define an operator to change a sequence element while keeping the sequence the same!

#v(0.5em)
(This one, some languages *do* get right; e.g. Java's strings are immutable)

== Consequences for Programming

If we want to implement high-level concepts following their mathematical theories,
there's no place for mutation.

- The theories do not admit it.
- Mutation can destroy useful laws in the theories.

Therefore, let's

- concentrate on defining theories for operators expressed as functions,
- avoid mutations,
- have powerful ways to abstract and compose functions.

== Functional Programming

- In a _restricted_ sense, functional programming (FP) means programming without mutable variables, assignments, loops, and other imperative control structures.
- In a _wider_ sense, functional programming means focusing on the functions and immutable data.
- In particular, functions can be values that are produced, consumed, and composed.
- All this becomes easier in a functional language.

== Functional Programming Languages

- In a _restricted_ sense, a functional programming language is one which does not have mutable variables, assignments, or imperative control structures.
- In a _wider_ sense, a functional programming language enables the
  construction of elegant programs that focus on functions and immutable data structures.
- In particular, functions in a FP language are first-class citizens. This means
  - they can be defined anywhere, including inside other functions
  - like any other value, they can be passed as parameters to functions and returned as results
  - as for other values, there exists a set of operators to compose functions

== Some functional programming languages

In the restricted sense:

- Pure Lisp, XSLT, XPath, XQuery, FP
- Haskell (without UnsafePerformIO & related escape hatches)

In the wider sense:

- (Lisp, Scheme), Racket, Clojure
- SML, Ocaml, #raw("F#")
- Haskell (full language)
- Scala
- (Smalltalk, Ruby, JavaScript)

(...): languages with first class functions but incomplete support for immutable data

== History of FP languages

#v(0.5em)
#table(
  columns: (auto, 1fr, auto, 1fr),
  stroke: none,
  inset: 8pt,
  fill: (_, y) => if calc.even(y) { white.darken(10%) },
  [1959],[ (Lisp) ],[2003],[ Scala ],
  [1975-77],[ ML, FP, Scheme ],[2005],[ #raw("F#") ],
  [1978],[ (Smalltalk) ],[2007],[ Clojure ],
  [1986],[ Standard ML ],[2012],[ Elixir ],
  [1990],[ Haskell, Erlang ],[2014],[ Swift ],
  [2000],[ OCaml ],[2017],[ Idris ],
  [ ],[ ],[2020],[ Scala 3 ],
)

#v(0.5em)
Scala 3 is the language we use in this course.

/*
Fortran was the first compiled language, but was very low-level (von Neumann model).

Lisp came only two years later, and was the first to have a GC:
in Fortran, creating data structures requires the manual allocation and deallocation of memory;
in Lisp, this is all handled automatically (implicitly) by the garbage collector.

Profound impact: all following fun prog langs adoped Lisp-style GC
and how it’s one of the main enablers of FP. */

