#pragma include("OctahedronMapping.xsh")
#pragma include("RGBM.xsh")
#pragma include("Color.xsh")

#define X_ROUGHNESS_MIP_COUNT 8

Vec3 xDiffuseIBL(Texture2D octahedron, Vec3 N)
{
	return xGammaToLinear(xDecodeRGBM(Sample(octahedron, xVec3ToOctahedronUv(N))));
}

/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
Vec3 xSpecularIBL(Texture2D octahedron, Vec2 texel, Texture2D brdf, Vec3 f0, float roughness, Vec3 N, Vec3 V)
{
	float NdotV = clamp(dot(N, V), 0.0, 1.0);
	Vec3 R = 2.0 * dot(V, N) * N - V;
	Vec2 envBRDF = Sample(brdf, Vec2(roughness, NdotV)).xy;

	float s = 1.0 / float(X_ROUGHNESS_MIP_COUNT);
	float r = roughness * float(X_ROUGHNESS_MIP_COUNT);
	float r2 = floor(r);
	float rDiff = r - r2;

	Vec2 uv0 = xVec3ToOctahedronUv(R);
	uv0.x = (r2 + Lerp(texel, 1.0 - texel, uv0.x)) * s;
	uv0.y = Lerp(texel, 1.0 - texel, uv0.y);

	Vec2 uv1 = uv0;
	uv1.x = uv1.x + s;

	Vec3 specular = f0 * envBRDF.x + envBRDF.y;

	Vec3 col0 = xGammaToLinear(xDecodeRGBM(Sample(octahedron, uv0))) * specular;
	Vec3 col1 = xGammaToLinear(xDecodeRGBM(Sample(octahedron, uv1))) * specular;

	return Lerp(col0, col1, rDiff);
}
