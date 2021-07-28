# Xpanda
> Xpanda is a tool that allows you to include code from external files into your shaders, while also trying to handle shader compatibility.

![License](https://img.shields.io/github/license/GameMakerDiscord/Xpanda)

Maintained by: [kraifpatrik](https://github.com/kraifpatrik)

Donate: [PayPal.Me](https://www.paypal.me/kraifpatrik/1usd)

# Table of Contents
* [Features](#features)
* [Installation](#installation)
* [Writing compatible shader code](#writing-compatible-shader-code)
* [Constants](#constants)
* [Directives](#directives)
  - [Include](#include)
  - [Branching](#branching)
* [Running Xpanda](#running-xpanda)
* [Projects using Xpanda](#projects-using-xpanda)

# Features
* Recursive inclusion of external files
* Support for sharing code between GLSL and HLSL
* Custom constants and branching directives evaluation - great for shader permutations!
* Code minification - remove comments and redundant whitespace from code - in case you don't want to include them in your executables!

# Installation
* Requires [Python 3](https://www.python.org/)

```cmd
git clone https://github.com/GameMakerDiscord/Xpanda
cd .\Xpanda
python.exe -m venv env
.\env\Scripts\Activate.ps1
pip.exe install -r requirements.txt
pyinstaller.exe --onefile Xpanda.py
```

*It is recommended to add C:\path\to\Xpanda\dist into your PATH to be able to run Xpanda from anywhere.*

# Writing compatible shader code
When writing includable shader code, you can use following Xpanda types / functions, which are automatically translated to their GLSL / HLSL equivalent.

Xpanda            | GLSL equivalent    | HLSL9 / HLSL11 equivalent
----------------- | ------------------ | -------------------------
Texture2D         | sampler2D          | sampler2D / Texture2D
Vec2              | vec2               | float2
Vec3              | vec3               | float3
Vec4              | vec4               | float4
Mat2              | mat2               | float2x2
Mat3              | mat3               | float3x3
Mat4              | mat4               | float4x4
Sample(tex, uv)   | texture2D(tex, uv) | tex2D(tex, uv) / tex.Sample(gm_BaseTexture, uv)
DDX(x)            | dFdx(x)            | ddx(x)
DDY(y)            | dFdy(y)            | ddy(y)
Frac(x)           | fract(x)           | frac(x)
Lerp(a,b,x)       | mix(a,b,x)         | lerp(a,b,x)
Rsqrt(x)          | inversesqrt(x)     | rsqrt(x)
Mod(x)            | mod(x)             | fmod(x)

# Constants
By default Xpanda defines following constants:

Constant  | Value
--------- | -----
`XGLSL`   | `true` if the target language is GLSL, otherwise `false`
`XHLSL`   | `true` if the target language is HLSL9 or HLSL11, otherwise `false`
`XHLSL9`  | `true` if the target language is HLSL9, otherwise `false`
`XHLSL11` | `true` if the target language is HLSL11, otherwise `false`

It is also possible to define custom constants through command line parameters.

**All occurrences of constants are automatically replaced by their values!**

Constants are especially handy in [branching](#branching), where they can be used to easily create shader permutations.

# Directives

## Include
To tell Xpanda that you want to include code into your shader, simply write

```cpp
#pragma include("filename"[, "language"])
```

where:
- `filename` is path to the included file (relative to the directory containing the includable files); for subfolders always use "/",
- `language` is the language in which are your shaders written (glsl, hlsl9 or hlsl11).

The process of expanding the includes is recursive, that means you can also include files from within the included files. Xpanda also deals with cyclic reference by simply never including the same file into one shader twice. It is also not necessary to delete the included code by hand before running Xpanda again, it's done automatically!

**Including HLSL code from shader earlier specified as GLSL (or vice versa) will cause error!**

## Branching
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

### Examples:
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

# Running Xpanda
Xpanda has a just a few command line parameters. To help you get started, you can first run following command, which will display a help message. In this message you can find all parameters and their descriptions.

```cmd
Xpanda.exe -h
```

# Projects using Xpanda
* [BBMOD](https://marketplace.yoyogames.com/assets/9424/bbmod)
* [BBP](https://blueburn.cz/index.php?menu=bbp)
* [CE](https://github.com/kraifpatrik/ce)
* Your project here?
