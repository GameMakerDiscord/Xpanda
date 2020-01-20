struct VS_out
{
	float4 Position : SV_POSITION;
	//float3 Normal   : NORMAL0;
	float4 Color    : COLOR0;
	float2 TexCoord : TEXCOORD0;
};

struct PS_out
{
	float4 Target0 : SV_TARGET0;
};

#pragma include("IntegrateBRDF.xsh")
#define X_PI   3.14159265359
#define X_2_PI 6.28318530718

/// @return x^2
float xPow2(float x) { return (x * x); }

/// @return x^3
float xPow3(float x) { return (x * x * x); }

/// @return x^4
float xPow4(float x) { return (x * x * x * x); }

/// @return x^5
float xPow5(float x) { return (x * x * x * x * x); }

/// @desc Mirrors the binary representation of i at the decimal point???
/// @source http://holger.dammertz.org/stuff/notes_HammersleyOnHemisphere.html
float xRadicalInverseVDC(uint i)
{
	uint b = (i << 16) | (i >> 16);
	b = ((b & 0x55555555) << 1) | ((b & 0xAAAAAAAA) >> 1);
	b = ((b & 0x33333333) << 2) | ((b & 0xCCCCCCCC) >> 2);
	b = ((b & 0x0F0F0F0F) << 4) | ((b & 0xF0F0F0F0) >> 4);
	b = ((b & 0x00FF00FF) << 8) | ((b & 0xFF00FF00) >> 8);
	return float(b) * 2.3283064365386963 * 0.0000000001;
}

/// @desc Gets i-th point from sequence of uniformly distributed points on a unit square.
/// @param i The point index in sequence.
/// @param n The total size of the sequence.
/// @source http://holger.dammertz.org/stuff/notes_HammersleyOnHemisphere.html
float2 xHammersley2D(int i, int n)
{
	return float2(float(i) / float(n), xRadicalInverseVDC(i));
}


/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
float3 xImportanceSample(float phi, float cosTheta, float sinTheta, float3 N)
{
	float3 H = float3(sinTheta * cos(phi), sinTheta * sin(phi), cosTheta);
	float3 upVector = abs(N.z) < 0.999 ? float3(0.0, 0.0, 1.0) : float3(1.0, 0.0, 0.0);
	float3 tangentX = normalize(cross(upVector, N));
	float3 tangentY = cross(N, tangentX);
	return tangentX*H.x + tangentY*H.y + N*H.z;
}

/// @source http://holger.dammertz.org/stuff/notes_HammersleyOnHemisphere.html
float3 xImportanceSample_Lambert(float2 Xi, float3 N)
{
	float phi = 2.0 * X_PI * Xi.y;
	float cosTheta = sqrt(1.0 - Xi.x);
	float sinTheta = sqrt(1.0 - cosTheta * cosTheta);
	return xImportanceSample(phi, cosTheta, sinTheta, N);
}

/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
float3 xImportanceSample_GGX(float2 Xi, float3 N, float roughness)
{
	float a = roughness*roughness;
	float phi = 2.0 * X_PI * Xi.x;
	float cosTheta = sqrt((1.0 - Xi.y) / (1.0 + (a * a - 1.0) * Xi.y));
	float sinTheta = sqrt(1.0 - cosTheta * cosTheta);
	return xImportanceSample(phi, cosTheta, sinTheta, N);
}


/// @desc Default specular color for dielectrics
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
#define X_F0_DEFAULT float3(0.04, 0.04, 0.04)

/// @desc Normal distribution function
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
float xSpecularD_GGX(float roughness, float NdotH)
{
	float r2 = roughness * roughness;
	float a = NdotH * NdotH * (r2 - 1.0) + 1.0;
	return r2 / (X_PI * a * a);
	// return r2 / (X_PI * xPow2(xPow2(NdotH) * (r2 - 1.0) + 1.0);
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
float3 xSpecularF_Schlick(float3 f0, float NdotV)
{
	return f0 + (1.0 - f0) * xPow5(1.0 - NdotV); 
}

/// @desc Cook-Torrance microfacet specular shading
/// @note N = normalize(vertexNormal)
///       L = normalize(light - vertex)
///       V = normalize(camera - vertex)
///       H = normalize(L + V)
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
float3 xBRDF(float3 f0, float roughness, float NdotL, float NdotV, float NdotH)
{
	float3 specular = xSpecularD_GGX(roughness, NdotH)
		* xSpecularF_Schlick(f0, NdotV)
		* xSpecularG_Schlick(xK_Analytic(roughness), NdotL, NdotH);
	return specular / (4.0 * NdotL * NdotV);
}


/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
float2 xIntegrateBRDF(float roughness, float NdotV)
{
	float3 V = float3(sqrt(1.0 - NdotV*NdotV), 0.0, NdotV);
	float3 N = float3(0.0, 0.0, 1.0);
	float a = 0.0;
	float b = 0.0;
	const int numSamples = 1024;
	float k = xK_IBL(roughness);
	for (int i = 0; i < numSamples; ++i)
	{
		float2 Xi = xHammersley2D(i, numSamples);
		float3 H = xImportanceSample_GGX(Xi, N, roughness);
		float3 L = 2.0 * dot(V, H) * H - V;
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
	return float2(a, b) / float(numSamples);
}

// include("IntegrateBRDF.xsh")

void main(in VS_out IN, out PS_out OUT)
{
	OUT.Target0.rg = xIntegrateBRDF(IN.TexCoord.x, IN.TexCoord.y);
	//OUT.Target0.rg = IN.TexCoord.xy;
	OUT.Target0.ba = float2(0.0, 1.0);
}