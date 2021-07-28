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
