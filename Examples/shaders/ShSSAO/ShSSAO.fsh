// Source: https://john-chapman-graphics.blogspot.cz/2013/01/ssao-tutorial.html

//> Comment out if you are using view-space normals instead
//> of world-space. This line is also present in the xSsaoInit script,
//> so don't forget to comment out that one as well!
#define X_SSAO_WORLD_SPACE_NORMALS

//> Must be the same values as in the xSsaoInit script!
#define X_SSAO_KERNEL_SIZE 16

varying vec2 v_vTexCoord;

#define texDepth  gm_BaseTexture
uniform sampler2D texNormal;
uniform sampler2D texRandom;
#ifdef X_SSAO_WORLD_SPACE_NORMALS
uniform mat4 u_mView;
#endif
uniform mat4  u_mProjection;
uniform vec2  u_vTexel;                            //< (1/screenWidth,1/screenHeight)
uniform vec2  u_vTanAspect;                        //< (dtan(fov/2)*(screenWidth/screenHeight),-dtan(fov/2))
uniform float u_fClipFar;                          //< Distance to the far clipping plane.
uniform vec3  u_vSampleKernel[X_SSAO_KERNEL_SIZE]; //< Kernel of random vectors.
uniform vec2  u_vNoiseScale;                       //< (screenWidth,screenHeight)/X_SSAO_NOISE_TEXTURE_SIZE
uniform float u_fPower;                            //< Strength of the occlusion effect.
uniform float u_fRadius;                           //< Radius of the occlusion effect.
uniform float u_fBias;                             //< Depth bias of the occlusion effect.

#pragma include("DepthEncoding.xsh", "glsl")
/// @param d Linearized depth to encode.
/// @return Encoded depth.
vec3 xEncodeDepth(float d)
{
	const float inv255 = 1.0 / 255.0;
	vec3 enc;
	enc.x = d;
	enc.y = d * 255.0;
	enc.z = enc.y * 255.0;
	enc = fract(enc);
	float temp = enc.z * inv255;
	enc.x -= enc.y * inv255;
	enc.y -= temp;
	enc.z -= temp;
	return enc;
}

/// @param c Encoded depth.
/// @return Docoded linear depth.
float xDecodeDepth(vec3 c)
{
	const float inv255 = 1.0 / 255.0;
	return c.x + c.y*inv255 + c.z*inv255*inv255;
}
// include("DepthEncoding.xsh")
#pragma include("Projecting.xsh", "glsl")
/// @param tanAspect (tanFovY*(screenWidth/screenHeight),-tanFovY), where
///                  tanFovY = dtan(fov*0.5)
/// @param texCoord  Sceen-space UV.
/// @param depth     Scene depth at texCoord.
/// @return Point projected to view-space.
vec3 xProject(vec2 tanAspect, vec2 texCoord, float depth)
{
	return vec3(tanAspect * (texCoord * 2.0 - 1.0) * depth, depth);
}

/// @param p A point in clip space (transformed by projection matrix, but not
///          normalized).
/// @return P's UV coordinates on the screen.
vec2 xUnproject(vec4 p)
{
	vec2 uv = p.xy / p.w;
	uv = uv * 0.5 + 0.5;
	uv.y = 1.0 - uv.y;
	return uv;
}
// include("Projecting.xsh")

void main()
{
	// Origin
	float depth = xDecodeDepth(texture2D(texDepth, v_vTexCoord).rgb);
	if (depth == 0.0 || depth == 1.0)
	{
		gl_FragColor = vec4(1.0);
		return;
	}
	depth *= u_fClipFar;
	vec3 origin = xProject(u_vTanAspect, v_vTexCoord, depth);

	// Calc. TBN matrix
	vec3 normal    = normalize(texture2D(texNormal, v_vTexCoord).rgb * 2.0 - 1.0);
#ifdef X_SSAO_WORLD_SPACE_NORMALS
	normal         = normalize((u_mView * vec4(normal, 0.0)).xyz);
#endif
	vec3 random    = texture2D(texRandom, v_vTexCoord * u_vNoiseScale).xyz * 2.0 - 1.0;
	vec3 tangent   = normalize(random - normal * dot(random, normal));
	vec3 bitangent = cross(normal, tangent);
	mat3 TBN       = mat3(tangent, bitangent, normal);

	// Occlusion
	float occlusion = 0.0;
	for (int i = 0; i < X_SSAO_KERNEL_SIZE; ++i)
	{
		// Get a sample in view-space and get it's screen-space coordinates
		vec3 sampleVS = origin + (TBN * u_vSampleKernel[i]) * u_fRadius;
		vec2 sampleUV = xUnproject(u_mProjection * vec4(sampleVS, 1.0));

		// Calc. occlusion
		float sampleDepth = xDecodeDepth(texture2D(texDepth, sampleUV).rgb);
		if (sampleDepth != 0.0 && sampleDepth != 1.0)
		{
			sampleDepth       *= u_fClipFar;
			float attenuation =  smoothstep(0.0, 1.0, u_fRadius / abs(origin.z - sampleDepth + u_fBias));
			occlusion         += attenuation * step(sampleDepth, sampleVS.z);
			//if (abs(origin.z - sampleDepth/* + u_fBias*/) < u_fRadius)
			//{
			//	occlusion += step(sampleDepth, sampleVS.z);
			//}
		}
	}
	occlusion = clamp(1.0 - occlusion / float(X_SSAO_KERNEL_SIZE), 0.0, 1.0);
	occlusion = pow(occlusion, u_fPower);

	// Output
	gl_FragColor.rgb = vec3(occlusion);
	gl_FragColor.a   = 1.0;
}