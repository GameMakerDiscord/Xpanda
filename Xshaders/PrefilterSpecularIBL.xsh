#pragma include("CubeMapping.xsh")
#pragma include("Hammersley2D.xsh")
#pragma include("ImportanceSampling.xsh")

/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
Vec3 xPrefilterIBL_GGX(Texture2D cubemap, Vec2 texel, Vec3 R)
{
	Vec3 N = R;
	Vec3 V = R;
	Vec3 prefilteredColor = Vec3(0.0, 0.0, 0.0);
	float totalWeight = 0.0;
	const int numSamples = 1024;
	for (int i = 0; i < numSamples; ++i)
	{
		Vec2 Xi = xHammersley2D(i, numSamples);
		Vec3 H = xImportanceSample_GGX(Xi, N, roughness);
		Vec3 L = 2.0 * dot(V, H) * H - V;
		float NdotL = clamp(dot(N, L), 0.0, 1.0);
		if (NdotL > 0.0)
		{
			prefilteredColor += Sample(cubemap, xVec3ToCubeUv(L, texel)).rgb * NdotL;
			totalWeight += NdotL;
		}
	}
	return prefilteredColor / totalWeight;
}
