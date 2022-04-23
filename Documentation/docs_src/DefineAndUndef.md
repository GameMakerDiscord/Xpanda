# Define and undef
Just like you can define additional symbols and their values for the preprocessor
when running Xpanda from the command like so:

```cmd
Xpanda.exe file.fsh CONSTANT=1
```
you can also define them in the expanded files themselves using the `#define`
directive. The only difference is that the symbol names must start with `X_`
(uppercase letter x and underscore):

```cpp
#define X_CONSTANT 1
```

This can be very useful for example when creating many permutations of the same
file:

```cpp
// Uber.vsh:
#ifdef X_A
    // Do something when X_A is defined...
#endif

#ifdef X_B
    // Do something when X_B is defined...
#endif

// File 1:
#define X_A
#pragma include("Uber.vsh")

// File 2:
#define X_B
#pragma include("Uber.vsh")
```

Which would expand to:

```cpp
// File 1:
#define X_A
#pragma include("Uber.vsh")
    // Do something when X_A is defined...
// include("Uber.vsh")

// File 2:
#define X_B
#pragma include("Uber.vsh")
    // Do something when X_B is defined...
// include("Uber.vsh")
```

You can also undefine these symbols later using the `#undef` macro:

```cpp
#define X_A

#ifdef X_A
    // This WILL be included, because X_A is defined.
#endif

#undef X_A

#ifdef X_A
    // This WILL NOT be included, because X_A is not defined anymore at this
    // point!
#endif
```
