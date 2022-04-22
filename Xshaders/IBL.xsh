#pragma include("OctahedronMapping.xsh")
#pragma include("RGBM.xsh")
#pragma include("Color.xsh")

Vec3 xDiffuseIBL(Texture2D ibl, Vec2 texel, Vec3 N)
{
	const float s = 1.0 / 8.0;
	const float r2 = 7.0;

	Vec2 uv0 = xVec3ToOctahedronUv(N);
	uv0.x = (r2 + Lerp(texel.x, 1.0 - texel.x, uv0.x)) * s;
	uv0.y = Lerp(texel.y, 1.0 - texel.y, uv0.y);

	return xGammaToLinear(xDecodeRGBM(texture2D(ibl, uv0)));
}

/// @source https://www.unrealengine.com/en-US/blog/physically-based-shading-on-mobile
Vec2 xEnvBRDFApprox(float roughness, float NdotV)
{
	const Vec4 c0 = Vec4(-1.0, -0.0275, -0.572, 0.022);
	const Vec4 c1 = Vec4(1.0, 0.0425, 1.04, -0.04);
	Vec4 r = (roughness * c0) + c1;
	float a004 = (min(r.x * r.x, exp2(-9.28 * NdotV)) * r.x) + r.y;
	return ((vec2(-1.04, 1.04) * a004) + r.zw);
}

/// @source https://www.unrealengine.com/en-US/blog/physically-based-shading-on-mobile
float xEnvBRDFApproxNonmetal(float roughness, float NdotV)
{
	// Same as EnvBRDFApprox(0.04, Roughness, NdotV)
	const Vec2 c0 = Vec2(-1.0, -0.0275);
	const Vec2 c1 = Vec2(1.0, 0.0425);
	Vec2 r = (roughness * c0) + c1;
	return (min(r.x * r.x, exp2(-9.28 * NdotV)) * r.x) + r.y;
}

// Fully rough optimization:
// xEnvBRDFApprox(SpecularColor, 1, 1) == SpecularColor * 0.4524 - 0.0024
// DiffuseColor += SpecularColor * 0.45;
// SpecularColor = 0.0;

/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
Vec3 xSpecularIBL(Texture2D ibl, Vec2 texel/*, Texture2D brdf*/, Vec3 f0, float roughness, Vec3 N, Vec3 V)
{
	float NdotV = clamp(dot(N, V), 0.0, 1.0);
	Vec3 R = 2.0 * dot(V, N) * N - V;
	// Vec2 envBRDF = Sample(brdf, Vec2(roughness, NdotV)).xy;
	Vec2 envBRDF = xEnvBRDFApprox(roughness, NdotV);

	const float s = 1.0 / 8.0;
	float r = roughness * 7.0;
	float r2 = floor(r);
	float rDiff = r - r2;

	Vec2 uv0 = xVec3ToOctahedronUv(R);
	uv0.x = (r2 + Lerp(texel.x, 1.0 - texel.x, uv0.x)) * s;
	uv0.y = Lerp(texel.y, 1.0 - texel.y, uv0.y);

	Vec2 uv1 = uv0;
	uv1.x = uv1.x + s;

	Vec3 specular = f0 * envBRDF.x + envBRDF.y;

	Vec3 col0 = xGammaToLinear(xDecodeRGBM(Sample(ibl, uv0))) * specular;
	Vec3 col1 = xGammaToLinear(xDecodeRGBM(Sample(ibl, uv1))) * specular;

	return Lerp(col0, col1, rDiff);
}
