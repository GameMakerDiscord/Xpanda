// Source: https://www.geeks3d.com/20110405/fxaa-fast-approximate-anti-aliasing-demo-glsl-opengl-test-radeon-geforce/3/

#define FXAA_REDUCE_MIN (1.0 / 128.0)
#define FXAA_REDUCE_MUL (1.0 / 8.0)
#define FXAA_SPAN_MAX   8.0

/// @param tex     Input texture.
/// @param fragPos Output of xFxaaFragPos.
/// @param texel   Vec2(1.0 / textureWidth, 1.0 / textureHeight)
Vec4 xFxaa(Texture2D tex, Vec4 fragPos, Vec2 texel)
{
/*---------------------------------------------------------*/
	Vec3 rgbNW = Sample(tex, fragPos.zw).xyz;
	Vec3 rgbNE = Sample(tex, fragPos.zw + Vec2(1.0, 0.0) * texel).xyz;
	Vec3 rgbSW = Sample(tex, fragPos.zw + Vec2(0.0, 1.0) * texel).xyz;
	Vec3 rgbSE = Sample(tex, fragPos.zw + Vec2(1.0, 1.0) * texel).xyz;
	Vec3 rgbM  = Sample(tex, fragPos.xy).xyz;
/*---------------------------------------------------------*/
	Vec3 luma = Vec3(0.299, 0.587, 0.114);
	float lumaNW = dot(rgbNW, luma);
	float lumaNE = dot(rgbNE, luma);
	float lumaSW = dot(rgbSW, luma);
	float lumaSE = dot(rgbSE, luma);
	float lumaM  = dot(rgbM,  luma);
/*---------------------------------------------------------*/
	float lumaMin = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));
	float lumaMax = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));
/*---------------------------------------------------------*/
	Vec2 dir;
	dir.x = -((lumaNW + lumaNE) - (lumaSW + lumaSE));
	dir.y =  ((lumaNW + lumaSW) - (lumaNE + lumaSE));
/*---------------------------------------------------------*/
	float dirReduce = max(
		(lumaNW + lumaNE + lumaSW + lumaSE) * (0.25 * FXAA_REDUCE_MUL),
		FXAA_REDUCE_MIN);
	float rcpDirMin = 1.0 / (min(abs(dir.x), abs(dir.y)) + dirReduce);
	dir = min(Vec2(FXAA_SPAN_MAX, FXAA_SPAN_MAX),
		max(Vec2(-FXAA_SPAN_MAX, -FXAA_SPAN_MAX),
		dir * rcpDirMin)) * texel;
/*--------------------------------------------------------*/
	Vec3 rgbA = (1.0 / 2.0) * (
		Sample(tex, fragPos.xy + dir * (1.0 / 3.0 - 0.5)).xyz +
		Sample(tex, fragPos.xy + dir * (2.0 / 3.0 - 0.5)).xyz);
	Vec3 rgbB = rgbA * (1.0 / 2.0) + (1.0 / 4.0) * (
		Sample(tex, fragPos.xy + dir * (0.0 / 3.0 - 0.5)).xyz +
		Sample(tex, fragPos.xy + dir * (3.0 / 3.0 - 0.5)).xyz);
	float lumaB = dot(rgbB, luma);
	Vec4 ret;
	ret.xyz = ((lumaB < lumaMin) || (lumaB > lumaMax)) ? rgbA : rgbB;
	ret.w = 1.0;
	return ret;
}
