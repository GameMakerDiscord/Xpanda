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
/// @source http://aras-p.info/blog/2009/07/30/encoding-floats-to-rgba-the-final/
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
/// @source http://aras-p.info/blog/2009/07/30/encoding-floats-to-rgba-the-final/
float xDecodeDepth(float3 c)
{
	const float inv255 = 1.0 / 255.0;
	return c.x + (c.y * inv255) + (c.z * inv255 * inv255);
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
#define X_CUBEMAP_POS_X 0
#define X_CUBEMAP_NEG_X 1
#define X_CUBEMAP_POS_Y 2
#define X_CUBEMAP_NEG_Y 3
#define X_CUBEMAP_POS_Z 4
#define X_CUBEMAP_NEG_Z 5

/// @param dir Sampling direction vector in world-space.
/// @param texel Texel size on cube side. Used to inset uv coordinates for
/// seamless filtering on edges. Use 0 to disable.
/// @return UV coordinates for the following cubemap layout:
/// +---------------------------+
/// |+X|-X|+Y|-Y|+Z|-Z|None|None|
/// +---------------------------+
float2 xVec3ToCubeUv(float3 dir, float2 texel)
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
	uv = lerp(texel * 1.5, 1.0 - texel * 1.5, uv);
	uv.x = (float(i) * 2.0 + o + uv.x) * 0.125;
	return uv;
}

/// @desc Gets normalized vector pointing to the UV on given cube side.
float3 xCubeUvToVec3Normalized(float2 uv, int cubeSide)
{
	uv.x = 1.0 - uv.x;
	uv = uv * 2.0 - 1.0;
	if (cubeSide == X_CUBEMAP_POS_X)
	{
		return normalize(float3(+1.0, -uv.x, -uv.y));
	}
	if (cubeSide == X_CUBEMAP_NEG_X)
	{
		return normalize(float3(-1.0, uv.x, -uv.y));
	}
	if (cubeSide == X_CUBEMAP_POS_Y)
	{
		return normalize(float3(uv.x, +1.0, -uv.y));
	}
	if (cubeSide == X_CUBEMAP_NEG_Y)
	{
		return normalize(float3(-uv.x, -1.0, -uv.y));
	}
	if (cubeSide == X_CUBEMAP_POS_Z)
	{
		return normalize(float3(uv.x, uv.y, +1.0));
	}
	if (cubeSide == X_CUBEMAP_NEG_Z)
	{
		return normalize(float3(uv.x, -uv.y, -1.0));
	}
	return float3(0.0, 0.0, 0.0);
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

/// @source https://learnopengl.com/Advanced-Lighting/Shadows/Shadow-Mapping
float xShadowMapPCF(Texture2D shadowMap, float2 texel, float2 uv, float compareZ)
{
	float shadow = 0.0;
	for (float x = -1.0; x <= 1.0; x += 1.0)
	{
		for (float y = -1.0; y <= 1.0; y += 1.0)
		{
			shadow += xShadowMapCompare(shadowMap, texel, uv.xy + (float2(x, y) * texel), compareZ);
		}
	}
	return (shadow / 9.0);
}

/// @source https://learnopengl.com/Advanced-Lighting/Shadows/Point-Shadows
float xShadowMapCube(Texture2D shadowMap, float2 texel, float3 dir, float compareZ)
{
	return xShadowMapCompare(shadowMap, texel, xVec3ToCubeUv(dir, texel.yy), compareZ);
}

/// @source https://learnopengl.com/Advanced-Lighting/Shadows/Point-Shadows
float xShadowMapPCFCube(Texture2D shadowMap, float2 texel, float3 dir, float compareZ)
{
	float3 samples[20];
	samples[0] = float3( 1,  1,  1);
	samples[1] = float3( 1, -1,  1);
	samples[2] = float3(-1, -1,  1);
	samples[3] = float3(-1,  1,  1);
	samples[4] = float3( 1,  1, -1);
	samples[5] = float3( 1, -1, -1);
	samples[6] = float3(-1, -1, -1);
	samples[7] = float3(-1,  1, -1);
	samples[8] = float3( 1,  1,  0);
	samples[9] = float3( 1, -1,  0);
	samples[10] = float3(-1, -1,  0);
	samples[11] = float3(-1,  1,  0);
	samples[12] = float3( 1,  0,  1);
	samples[13] = float3(-1,  0,  1);
	samples[14] = float3( 1,  0, -1);
	samples[15] = float3(-1,  0, -1);
	samples[16] = float3( 0,  1,  1);
	samples[17] = float3( 0, -1,  1);
	samples[18] = float3( 0, -1, -1);
	samples[19] = float3( 0,  1, -1);

	float shadow = 0.0;
	for (int i = 0; i < 20; ++i)
	{
		shadow += xShadowMapCompare(shadowMap, texel, xVec3ToCubeUv(dir + samples[i], float2(texel.y, texel.y)), compareZ);
	}
	return (shadow / 20.0);
}

// include("ShadowMapping.xsh")
#pragma include("BRDF.xsh")
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


/// @desc Default specular color for dielectrics
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
#define X_F0_DEFAULT float3(0.04, 0.04, 0.04)

/// @desc Normal distribution function
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
float xSpecularD_GGX(float roughness, float NdotH)
{
	float r = xPow4(roughness);
	float a = NdotH * NdotH * (r - 1.0) + 1.0;
	return r / (X_PI * a * a);
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
float3 xSpecularF_Schlick(float3 f0, float VdotH)
{
	return f0 + (1.0 - f0) * xPow5(1.0 - VdotH); 
}

/// @desc Cook-Torrance microfacet specular shading
/// @note N = normalize(vertexNormal)
///       L = normalize(light - vertex)
///       V = normalize(camera - vertex)
///       H = normalize(L + V)
/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
float3 xBRDF(float3 f0, float roughness, float NdotL, float NdotV, float NdotH, float VdotH)
{
	float3 specular = xSpecularD_GGX(roughness, NdotH)
		* xSpecularF_Schlick(f0, VdotH)
		* xSpecularG_Schlick(xK_Analytic(roughness), NdotL, NdotH);
	return specular / max(4.0 * NdotL * NdotV, 0.001);
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

			float shadow = xShadowMapCube(texShadowMap, u_vShadowMapTexel, -lightVec, distLinear - bias);
			float att = xPow2(saturate(1.0 - xPow4(distLinear))) / (xPow2(dist) + 1.0);

			float3 lightCol = u_vLightCol.rgb * u_vLightCol.a * NdotL * att * (1.0 - shadow);

			float3 f0 = lerp(X_F0_DEFAULT, base, metalness);

			float3 V = normalize(u_vCamPos - posWorld);
			float3 H = normalize(L + V);

			float NdotV = saturate(dot(N, V));
			float NdotH = saturate(dot(N, H));
			float VdotH = saturate(dot(V, H));

			float3 specular = lightCol.rgb * xBRDF(f0, roughness, NdotL, NdotV, NdotH, VdotH);

			OUT.Total = float4(base * (lightCol / X_PI) * (1.0 - metalness) + specular, 1.0);
			OUT.Specular = float4(specular, 1.0);

			OUT.Total.rgb = pow(OUT.Total.rgb, 1.0 / 2.2);
			OUT.Specular.rgb = pow(OUT.Specular.rgb, 1.0 / 2.2);
		}
	}
}