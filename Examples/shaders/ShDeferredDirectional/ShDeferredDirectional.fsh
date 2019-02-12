struct VS_out
{
	float4 Position : SV_POSITION;
	float2 TexCoord : TEXCOORD0;
};

struct PS_out
{
	float4 Total    : SV_TARGET0; // Sum of diffuse and specular light.
	float4 Specular : SV_TARGET1; // Specular light only.
};

#define   texAlbedoAO               gm_BaseTextureObject
Texture2D texNormalRoughness      : register(t1);
Texture2D texDepthMetalness       : register(t2);
//Texture2D texEmissiveTranslucency : register(t3);
Texture2D texShadowMap            : register(t4);

uniform float4x4 u_mInverse;
uniform float4x4 u_mShadowMap;
uniform float    u_fShadowMapArea;
uniform float2   u_vShadowMapTexel; // (1/shadowMapWidth,1/shadowMapHeight)
uniform float    u_fClipFar;
uniform float2   u_vTanAspect;
uniform float3   u_vLightDir;
uniform float4   u_vLightCol;       // (r,g,b,intensity)
uniform float3   u_vCamPos;         // Camera's (x,y,z) position in world space.

#pragma include("DepthEncoding.xsh")
/// @param d Linearized depth to encode.
/// @return Encoded depth.
float3 xEncodeDepth(float d)
{
	const float inv255 = 1.0 / 255.0;
	float3 enc;
	enc.x = d;
	enc.y = d * 255.0;
	enc.z = enc.y * 255.0;
	enc = frac(enc);
	float temp = enc.z * inv255;
	enc.x -= enc.y * inv255;
	enc.y -= temp;
	enc.z -= temp;
	return enc;
}

/// @param c Encoded depth.
/// @return Docoded linear depth.
float xDecodeDepth(float3 c)
{
	const float inv255 = 1.0 / 255.0;
	return c.x + c.y*inv255 + c.z*inv255*inv255;
}
// include("DepthEncoding.xsh")
#pragma include("Projecting.xsh")
/// @param tanAspect (tanFovY*(screenWidth/screenHeight),-tanFovY), where
///                  tanFovY = dtan(fov*0.5)
/// @param texCoord  Sceen-space UV.
/// @param depth     Scene depth at texCoord.
/// @return Point projected to view-space.
float3 xProject(float2 tanAspect, float2 texCoord, float depth)
{
	return float3(tanAspect * (texCoord * 2.0 - 1.0) * depth, depth);
}

/// @param p A point in clip space (transformed by projection matrix, but not
///          normalized).
/// @return P's UV coordinates on the screen.
float2 xUnproject(float4 p)
{
	float2 uv = p.xy / p.w;
	uv = uv * 0.5 + 0.5;
	uv.y = 1.0 - uv.y;
	return uv;
}
// include("Projecting.xsh")
#pragma include("ShadowMapping.xsh")

/// @source http://codeflow.org/entries/2013/feb/15/soft-shadow-mapping/
float xShadowMapCompare(Texture2D shadowMap, float2 texel, float2 uv, float compareZ)
{
	if (uv.x < 0.0 || uv.y < 0.0
		|| uv.x > 1.0 || uv.y > 1.0)
	{
		return 0.0;
	}
	float2 temp = uv.xy / texel + 0.5;
	float2 f = frac(temp);
	float2 centroidUV = floor(temp) * texel;
	float2 pos = centroidUV;
	float lb = step(xDecodeDepth(shadowMap.Sample(gm_BaseTexture, pos).rgb), compareZ); // (0,0)
	pos.y += texel.y;
	float lt = step(xDecodeDepth(shadowMap.Sample(gm_BaseTexture, pos).rgb), compareZ); // (0,1)
	pos.x += texel.x;
	float rt = step(xDecodeDepth(shadowMap.Sample(gm_BaseTexture, pos).rgb), compareZ); // (1,1)
	pos.y -= texel.y;
	float rb = step(xDecodeDepth(shadowMap.Sample(gm_BaseTexture, pos).rgb), compareZ); // (1,0)
	return lerp(
		lerp(lb, lt, f.y),
		lerp(rb, rt, f.y),
		f.x);
}
// include("ShadowMapping.xsh")
#pragma include("BRDF.xsh")
#define X_PI   3.14159265359
#define X_2_PI 6.28318530718

/// @return x^2
float xPow2(float x) { return (x*x); }

/// @return x^3
float xPow3(float x) { return (x*x*x); }

/// @return x^4
float xPow4(float x) { return (x*x*x*x); }

/// @return x^5
float xPow5(float x) { return (x*x*x*x*x); }

/// @desc Default specular color for dielectrics.
#define X_F0_DEFAULT float3(0.22, 0.22, 0.22)

/// @desc Normal distribution function
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
float xSpecularD_GGX(float roughness, float NdotH)
{
	float r2 = roughness*roughness;
	float a = NdotH*NdotH*(r2-1.0) + 1.0;
	return r2 / (X_PI*a*a);
	// return r2 / (X_PI * xPow2(xPow2(NdotH) * (r2-1.0) + 1.0);
}

/// @desc Geometric attenuation
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
float xSpecularG_Schlick(float roughness, float NdotL, float NdotV)
{
	float k = xPow2(roughness+1.0) * 0.125;
	float oneMinusK = 1.0-k;
	return (NdotL / (NdotL*oneMinusK + k))
		* (NdotV / (NdotV*oneMinusK + k));
}

/// @desc Fresnel
/// @source https://en.wikipedia.org/wiki/Schlick%27s_approximation
float3 xSpecularF_Schlick(float3 f0, float NdotV)
{
	return f0 + (1.0-f0) * xPow5(1.0-NdotV); 
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
		* xSpecularG_Schlick(roughness, NdotL, NdotH);
	return specular / (4.0*NdotL*NdotV);
}
// include("BRDF.xsh")

void main(in VS_out IN, out PS_out OUT)
{
	float4 normalRoughness = texNormalRoughness.Sample(gm_BaseTexture, IN.TexCoord);
	if (dot(normalRoughness.xyz, 1.0) == 0.0)
	{
		discard;
	}

	float4 albedoAO             = texAlbedoAO.Sample(gm_BaseTexture, IN.TexCoord);
	float4 depthMetalness       = texDepthMetalness.Sample(gm_BaseTexture, IN.TexCoord);
	//float4 emissiveTranslucency = texEmissiveTranslucency.Sample(gm_BaseTexture, IN.TexCoord);

	float3 N     = normalize(normalRoughness.xyz * 2.0 - 1.0);
	float3 L     = -normalize(u_vLightDir);
	float  NdotL = saturate(dot(N, L));

	float  shadow   = 0.0;
	float4 lightCol = float4(0.0, 0.0, 0.0, 1.0);
	float4 specular = float4(0.0, 0.0, 0.0, 1.0);

	float3 base      = albedoAO.rgb;
	float  roughness = normalRoughness.a;
	float  metalness = depthMetalness.a;

	if (NdotL > 0.0)
	{
		float depth = xDecodeDepth(depthMetalness.xyz) * u_fClipFar;
		float3 posView = xProject(u_vTanAspect, IN.TexCoord, depth);
		float3 posWorld = mul(u_mInverse, float4(posView, 1.0)).xyz;
		float bias = 1.5;
		float3 posShadowMap = mul(u_mShadowMap, float4(posWorld + N * bias, 1.0)).xyz * 0.5 + 0.5;
		posShadowMap.y = 1.0 - posShadowMap.y;
		shadow = xShadowMapCompare(texShadowMap, u_vShadowMapTexel, posShadowMap.xy, posShadowMap.z);
		const float lerpRegion = 2.0;
		float shadowLerp = saturate((length(posView) - u_fShadowMapArea * 0.5 + lerpRegion) / lerpRegion);
		shadow = lerp(shadow, 0.0, shadowLerp);

		lightCol.rgb = u_vLightCol.rgb * u_vLightCol.a * NdotL * (1.0 - shadow);

		float3 f0 = lerp(X_F0_DEFAULT, base, metalness);

		float3 V = normalize(u_vCamPos - posWorld);
		float3 H = normalize(L + V);

		float NdotV = saturate(dot(N, V));
		float NdotH = saturate(dot(N, H));

		specular.rgb = lightCol.rgb * xBRDF(f0, roughness, NdotL, NdotV, NdotH);
	}

	OUT.Total = float4(base * lightCol * (1.0 - metalness), 1.0) + float4(specular.rgb, 0.0);
	OUT.Specular = specular;
}