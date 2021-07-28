#pragma include("CubeMapping.xsh")
#pragma include("Hammersley2D.xsh")
#pragma include("ImportanceSampling.xsh")
#pragma include("LogLUV.xsh")
#pragma include("Color.xsh")

/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
Vec3 xPrefilterIBL_Lambert(Texture2D cubemap, Vec2 texel, Vec3 N)
{
	Vec3 prefilteredColor = Vec3(0.0, 0.0, 0.0);
	float totalWeight = 0.0;
	const int numSamples = 1024;
	for (int i = 0; i < numSamples; ++i)
	{
		Vec2 Xi = xHammersley2D(i, numSamples);
		Vec3 L = xImportanceSample_Lambert(Xi, N);
		prefilteredColor += xDecodeLogLuv(Sample(cubemap, xVec3ToCubeUv(L, texel)));
	}
	return prefilteredColor / float(numSamples);
}
