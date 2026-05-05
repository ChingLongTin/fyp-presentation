
# Intro

Our final-year project implements a system, called Dynamic Staging, to the MLscript compiler.

We want to allow programmers to maintain general, high-level code, while the compiler automatically generates optimized versions of specific call sites of the functions.

Multi-Stage Programming is one possible way to achieve this, which is done by:
- Starting with some functions that we want to optimize
- Adding staging annotations to the program, turning the function into a program generator, specifying how the code should be partially evaluated
- Compiling the module to create a optimized residual module to be imported

This approach has some additional work for library managers, as they need to anticipate the use cases of certain functions to add the annotations at the appropriate locations.

But what if we can reduce the work to a single "staged" annotation, while maintaining the same specialization capabilities?

This is what is provided by Dynamic Staging.

<!-- 43s -->

# Approach

We describe the approach in three steps.

After marking the module as staged, we perform the first step, instrumentation, which converts the module into a program generator module.

We define an intermediate representation written in MLscript called Staged Block, which we will use to represent the syntax tree of a program. During compilation, the functions in the program generator module are converted to a representation of the original program in Staged Block. This lets us perform reflection on the program for optimization.

When the program generator module is executed, we perform the second step, shape propagation, optimizing the representation of the program. In this step, we use the fact that variables in the program can only attain certain shapes, making certain parts of the code redundant.

After the representation is optimized, we perform the third step, turning the represented code into a residual module.

<!-- 45s -->

# Shape Propagation (with example)

Let's use an example to show how shape propagation works.

In this module, we have several functions that call the function `foo` with various arguments. [The key thing here is that these functions could be written more efficiently, and this is what we will do here.]



As we can see, we have optimized the `test` functions, where the original calls are substituted with more optimized functions.

# Benchmark

We tested our dynamic staging system against a workload performing model-view-projection on a fixed transformation matrix, and we found that the staged version of the code has a better execution time, while having the trade-off of a larger code size from the generated specialized functions.

<!-- 15s -->