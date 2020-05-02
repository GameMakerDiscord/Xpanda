#pragma include("Math.xsh")
#pragma include("Hammersley2D.xsh")
#pragma include("ImportanceSampling.xsh")
#pragma include("BRDF.xsh")

/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
Vec2 xIntegrateBRDF(float roughness, float NdotV)
{
	Vec3 V = Vec3(sqrt(1.0 - NdotV*NdotV), 0.0, NdotV);
	Vec3 N = Vec3(0.0, 0.0, 1.0);
	float a = 0.0;
	float b = 0.0;
	const int numSamples = 8192;
	float k = xK_IBL(roughness);
	for (int i = 0; i < numSamples; ++i)
	{
		Vec2 Xi = xHammersley2D(i, numSamples);
		Vec3 H = xImportanceSample_GGX(Xi, N, roughness);
		Vec3 L = 2.0 * dot(V, H) * H - V;
		float NdotL = clamp(L.z, 0.0, 1.0);
		float NdotH = clamp(H.z, 0.0, 1.0);
		float VdotH = clamp(dot(V, H), 0.0, 1.0);
		if (NdotL > 0.0)
		{
			float g = xSpecularG_Schlick(k, NdotL, NdotV);
			float gVis = (g * VdotH) / (NdotH * NdotV);
			float fc = xPow5(1.0 - VdotH);
			a += (1.0 - fc) * gVis;
			b += fc * gVis;
		}
	}
	return Vec2(a, b) / float(numSamples);
}
