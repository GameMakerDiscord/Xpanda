# Include
To tell Xpanda that you want to include code into your shader, simply write

```cpp
#pragma include("filename"[, "language"])
```

where:
- `filename` is path to the included file (relative to the directory containing the includable files); for subfolders always use "/",
- `language` is the language in which are your shaders written (glsl, hlsl9 or hlsl11).

The process of expanding the includes is recursive, that means you can also include files from within the included files. Xpanda also deals with cyclic reference by simply never including the same file into one shader twice. It is also not necessary to delete the included code by hand before running Xpanda again, it's done automatically!

**Including HLSL code from shader earlier specified as GLSL (or vice versa) will cause error!**
