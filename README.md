# Xpanda
Xpanda is a tool that allows you to include code from external files into your shaders, while also trying to handle shader compatibility.

Maintained by: [kraifpatrik](https://github.com/kraifpatrik)
Donate: [PayPal.Me](https://www.paypal.me/kraifpatrik/1usd)

# Table of Contents
 - [Writing compatible shader code](#writing-compatible-shader-code)
 - [Specifying includes](#specifying-includes)
 - [Running Xpanda](#running-xpanda)

## Writing compatible shader code
To handle compatiblity with GLSL and HLSL, follow this translation table:

Xpanda          | GLSL equivalent   | HLSL9 / HLSL11 equivalent
--------------- | ----------------- | -------------------------
Texture2D       | sampler2D         | sampler2D / Texture2D
Vec2            | vec2              | float2
Vec3            | vec3              | float3
Vec4            | vec4              | float4
Mat2            | mat2              | float2x2
Mat3            | mat3              | float3x3
Mat4            | mat4              | float4x4
Sample(tex, uv) | sample2D(tex, uv) | tex2D(tex, uv) / tex.Sample(gm_BaseTexture, uv)
DDX(x)          | dFdx(x)           | ddx(x)
DDY(y)          | dFdy(y)           | ddy(y)
Frac(x)         | fract(x)          | frac(x)
Lerp(a,b,x)     | mix(a,b,x)        | lerp(a,b,x)
Rsqrt(x)        | inversesqrt(x)    | rsqrt(x)

If the translation table does not provide a type name or a function that you need, you can use following guards:

```c
#if XGLSL
// Some GLSL-only code here...
#endif // XGLSL

#if XHLSL
// Some code compatible with both HLSL9 and HLSL11...
#endif // XHLSL

#if XHLSL9
// Some code compatible only with HLSL9...
#endif // XHLSL9

#if XHLSL11
// Some code compatible only with HLSL11...
#endif // XHLSL11
```

when included, Xpanda automatically removes code guarded by other language types than yours target language (as well as the guards for the target language).

## Specifying includes
To tell Xpanda that you want to include code into your shader, simply write

```c
#pragma include("filename"[, "language"])
```

where:
 - `filename` is path to the included file (relative to the directory containing the includable files, see [Running Xpanda](#running-xpanda)); for subfolders always use "/",
 - `language` is the language in which are your shaders written, can be omitted (see [Languages](#languages)).

The process of expanding the includes is recursive, that means you can also include files from within the included files. Xpanda also deals with cyclic reference by simply never including the same file into one shader twice. It is also not necessary to delete the included code by hand before running Xpanda again, it's done automatically!

**Note:** Including HLSL code from shader earlier specified as GLSL (or vice versa) will cause error!

## Running Xpanda
Requirements: the latest [Python 3](https://www.python.org/downloads/)

```
python Xpanda.py [-h] [--x EXTERNAL] [--o OUT] [--l LANG] PATH
```

Argument       | Explanation
-------------- | -----------
`PATH`         | path to the folder containing your shaders
`-h, --help`   | show help message and exit
`--x EXTERNAL` | path to the folder containing the external files (default is `./Xshaders/` (relative to the Xpanda directory))
`--o OUT`      | output directory for expanded shaders, `PATH` is used if not specified
`--l LANG`     | fallback shader language when not specified by include, see [Languages](#languages)

### Languages:
 - `glsl` (default)
 - `hlsl9`
 - `hlsl11`

### Example:
This will expand all includes in all files within the shaders directory of my project, taking the included files from the Xshaders directory. Since I know most of my shaders in the project are written in HLSL11, I can set it as the default language and rarely specify GLSL.

```
python Xpanda.py --x C:\Users\Patrik\Xshaders --l hlsl11 C:\Users\Patrik\GameMakerStudio2\Projects\MyProject\shaders
```
