
# Intro

We want to allow programmers to maintain general, high-level code, while the compiler automatically generates optimized versions of specific call sites of the functions.

Multi-Stage Programming is one possible way to achieve this, which is done by:
- Start with some functions that we want to optimize
- Add staging annotations, turning the function into a program generator, which specifies how the code should be partially evaluated
- Compile the module to create a residual, optimized module to be imported

This approach adds additional work for library managers, as they need to anticipate the use cases of certain functions.

But what if we can reduce the annotations to a single "staged" annotation, while maintaining the same specialization capabilities?

This is what is provided by our project.

<!-- 43s -->

# Approach

We convert this program generator module into an residual module in three steps.

The first step is the instrumentation.

We define an intermediate representation in MLscript that defines a syntax tree of a program. During compilation, the functions in the program generator module are converted to a representation of the original program. This lets us perform reflection on the program for optimization.

This program generator module is then compiled, leading to the second step, shape propagation, optimizing the representation of the program. In this step, we use the fact that variables in the program can only attain certain shapes to optimize the program.

After the representation is optimized, we perform the third step, turning the represented code into a residual module.

<!-- 45s -->

# Shape Propagation (with example)



# Benchmark

We tested our dynamic staging system against a workload performing model-view-projection on a fixed transformation matrix, and we found that the staged version of the code has a better execution time, while having the tradeoff of a larger code size from the generated specialized functions.

<!-- 15s -->