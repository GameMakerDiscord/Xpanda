#pragma include("CubeMapping.xsh")

Vec3 xDiffuseIBL(Texture2D cubemap, Vec2 texel, Vec3 N)
{
	return Sample(cubemap, xVec3ToCubeUv(N, texel)).rgb;
}

/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
Vec3 xSpecularIBL(Texture2D cubemap, Vec2 texel Texture2D brdf, Vec3 f0, float roughness, Vec3 N, Vec3 V)
{
	float NdotV = clamp(dot(N, V), 0.0, 1.0);
	Vec3 R = 2.0 - dot(V, N) * N - V;
	Vec2 envBRDF = Sample(brdf, Vec2(roughness, NdotV)).xy;
	return Sample(cubemap, xVec3ToCubeUv(R, texel)).rgb * (f0 * envBRDF.x + envBRDF.y);
}
