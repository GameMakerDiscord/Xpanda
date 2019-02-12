struct VS_out
{
	float4 Position : SV_POSITION;
	float4 Vertex   : TEXCOORD0;
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

uniform float2   u_vShadowMapTexel;
uniform float4x4 u_mInverse;
uniform float    u_fClipFar;
uniform float2   u_vTanAspect;
uniform float4   u_vLightPos;  // (x,y,z,radius)
uniform float4   u_vLightCol;  // (r,g,b,intensity)
uniform float3   u_vCamPos;    // Camera's (x,y,z) position in the world space

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
#pragma include("CubeMapping.xsh")
/// @param dir Sampling direction vector in world-space.
/// @return UV coordinates for the following cubemap layout:
/// +---------------------------+
/// |+X|-X|+Y|-Y|+Z|-Z|None|None|
/// +---------------------------+
float2 xVec3ToCubeUv(float3 dir)
{
	float3 dirAbs = abs(dir);

	int i = dirAbs.x > dirAbs.y ?
		(dirAbs.x > dirAbs.z ? 0 : 2) :
		(dirAbs.y > dirAbs.z ? 1 : 2);

	float uc, vc, ma;
	float o = 0.0;

	if (i == 0)
	{
		if (dir.x > 0.0)
		{
			uc = dir.y;
		}
		else
		{
			uc = -dir.y;
			o = 1.0;
		}
		vc = -dir.z;
		ma = dirAbs.x;
	}
	else if (i == 1)
	{
		if (dir.y > 0.0)
		{
			uc = -dir.x;
		}
		else
		{
			uc = dir.x;
			o = 1.0;
		}
		vc = -dir.z;
		ma = dirAbs.y;
	}
	else
	{
		uc = dir.y;
		if (dir.z > 0.0)
		{
			vc = +dir.x;
		}
		else
		{
			vc = -dir.x;
			o = 1.0;
		}
		ma = dirAbs.z;
	}

	float invL = 1.0 / length(ma);
	float2 uv = (float2(uc, vc) * invL + 1.0) * 0.5;
	uv.x = (float(i) * 2.0 + o + uv.x) * 0.125;
	return uv;
}
// include("CubeMapping.xsh")
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
	float2 screenUV       = xUnproject(IN.Vertex);
	float4 depthMetalness = texDepthMetalness.Sample(gm_BaseTexture, screenUV);

	float  depth    = xDecodeDepth(depthMetalness.xyz) * u_fClipFar;
	float3 posView  = xProject(u_vTanAspect, screenUV, depth);
	float3 posWorld = mul(u_mInverse, float4(posView, 1.0)).xyz;
	float3 lightVec = u_vLightPos.xyz - posWorld;
	float  dist     = length(lightVec);

	OUT.Total = 0.0;
	OUT.Specular = 0.0;

	if (dist < u_vLightPos.w)
	{
		float4 normalRoughness = texNormalRoughness.Sample(gm_BaseTexture, screenUV);
		float3 N    = normalize(normalRoughness.xyz * 2.0 - 1.0);
		float3 L    = normalize(lightVec);
		float NdotL = saturate(dot(N, L));

		if (NdotL > 0.0)
		{
			//float4 emissiveTranslucency = texEmissiveTranslucency.Sample(gm_BaseTexture, screenUV);
			float4 albedoAO  = texAlbedoAO.Sample(gm_BaseTexture, screenUV);
			float3 base      = albedoAO.rgb;
			float  roughness = normalRoughness.a;
			float  metalness = depthMetalness.a;

			float bias = 0.1 * tan(acos(NdotL));
			bias = clamp(bias, 0.0, 0.05);
			float distLinear = saturate(dist / u_vLightPos.w);

			float shadow = xShadowMapCompare(texShadowMap, u_vShadowMapTexel, xVec3ToCubeUv(-lightVec), distLinear - bias);
			float att = 1.0 - distLinear;

			float3 lightCol = u_vLightCol.rgb * u_vLightCol.a * NdotL * att * (1.0 - shadow);

			float3 f0 = lerp(X_F0_DEFAULT, base, metalness);

			float3 V = normalize(u_vCamPos - posWorld);
			float3 H = normalize(L + V);

			float NdotV = saturate(dot(N, V));
			float NdotH = saturate(dot(N, H));

			float3 specular = lightCol.rgb * xBRDF(f0, roughness, NdotL, NdotV, NdotH);
			
			OUT.Total = float4(base * lightCol * (1.0 - metalness) + specular, 1.0);
			OUT.Specular = float4(specular, 1.0);
		}
	}
}