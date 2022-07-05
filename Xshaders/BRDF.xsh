#pragma include("Math.xsh")

/// @desc Default specular color for dielectrics
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
#define X_F0_DEFAULT Vec3(0.04, 0.04, 0.04)

/// @desc Normal distribution function
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
float xSpecularD_GGX(float roughness, float NdotH)
{
	float r = xPow4(roughness);
	float a = NdotH * NdotH * (r - 1.0) + 1.0;
	return r / (X_PI * a * a);
}

/// @source https://www.unrealengine.com/en-US/blog/physically-based-shading-on-mobile
float xSpecularD_Approx(float roughness, float RdotL)
{
	float a = roughness * roughness;
	float a2 = a * a;
	float rcp_a2 = 1.0 / a2;
	// 0.5 / ln(2), 0.275 / ln(2)
	float c = (0.72134752 * rcp_a2) + 0.39674113;
	return (rcp_a2 * exp2((c * RdotL) - c));
}

/// @desc Roughness remapping for analytic lights.
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
float xK_Analytic(float roughness)
{
	return xPow2(roughness + 1.0) * 0.125;
}

/// @desc Roughness remapping for IBL lights.
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
float xK_IBL(float roughness)
{
	return xPow2(roughness) * 0.5;
}

/// @desc Geometric attenuation
/// @param k Use either xK_Analytic for analytic lights or xK_IBL for image based lighting.
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
float xSpecularG_Schlick(float k, float NdotL, float NdotV)
{
	return (NdotL / (NdotL * (1.0 - k) + k))
		* (NdotV / (NdotV * (1.0 - k) + k));
}

/// @desc Fresnel
/// @source https://en.wikipedia.org/wiki/Schlick%27s_approximation
Vec3 xSpecularF_Schlick(Vec3 f0, float VdotH)
{
	return f0 + (1.0 - f0) * xPow5(1.0 - VdotH);
}

/// @desc Cook-Torrance microfacet specular shading
/// @note N = normalize(vertexNormal)
///       L = normalize(light - vertex)
///       V = normalize(camera - vertex)
///       H = normalize(L + V)
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
Vec3 xBRDF(Vec3 f0, float roughness, float NdotL, float NdotV, float NdotH, float VdotH)
{
	Vec3 specular = xSpecularD_GGX(roughness, NdotH)
		* xSpecularF_Schlick(f0, VdotH)
		* xSpecularG_Schlick(xK_Analytic(roughness), NdotL, NdotH);
	return specular / ((4.0 * NdotL * NdotV) + 0.01);
}
