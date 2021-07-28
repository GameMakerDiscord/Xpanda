# Branching
Xpanda's preprocessor is also capable of branching:

```cpp
// Simple if
#if expression
  // ..
#endif

// If with else branch
#if expression
  // ...
#else
  // ...
#endif

// Branches like these can be simplified using elif
#if expression1
  // ...
#else
  #if expression2
    // ...
  #endif
#endif

#if expression1
  // ...
#elif expression2
  // ...
#endif

// You can chain as many elifs as you want
#if expression1
  // ...
#elif expression2
  // ...
#elif expression3
  // ...
#else
  // ...
#endif
```

In the current implementation, expressions are evaluated using Python's `eval`. If an expression evaluates to `true` (or anything that would pass in `if`), then the code is included in the shader. If Python fails to eval the expression, then both the directive and the code it surrounds are left in the shader!

C-like operators/keywords `&&`, `||`, `!`, `true`, `false` in expressions are automatically translated to their Python counterparts before eval. **You shouldn't directly use Python's `and`, `or`, `not`, `True`, `False` in expressions, since their evaluation process may be a subject to change in the future!**

## Examples:
```cpp
#if XGLSL
  // Code to include only in GLSL shaders
#else
  // Code to include only in HLSL shaders
#endif

#if XHLSL
  // Code common for both HLSL9 and HLSL11
  #if XHLSL9
    // HLSL9 specific code
  #else
    // HLSL11 specific code
  #endif
#endif

#if (X * 2 > 4) && !((A || B) && C)
  // Complex conditions like these are also supported
#endif
```
