varying vec4 v_vPosition;
varying vec4 v_vPositionWorld;
varying vec3 v_vNormal;
varying vec2 v_vTexCoord;

uniform sampler2D u_texLightIndex;
uniform sampler2D u_texLightData;
uniform vec3 u_vBboxMin;
uniform vec3 u_vBboxMax;
uniform vec2 u_vTanAspect;

#define LIGHT_RADIUS_MAX 1000.0
#define LIGHT_INTENSITY_MAX 16384.0

#pragma include("Color.xsh", "glsl")
#define X_GAMMA 2.2

/// @desc Converts gamma space color to linear space.
vec3 xGammaToLinear(vec3 rgb)
{
	return pow(rgb, vec3(X_GAMMA));
}

/// @desc Converts linear space color to gamma space.
vec3 xLinearToGamma(vec3 rgb)
{
	return pow(rgb, vec3(1.0 / X_GAMMA));
}

/// @desc Gets color's luminance.
float xLuminance(vec3 rgb)
{
	return (0.2126 * rgb.r + 0.7152 * rgb.g + 0.0722 * rgb.b);
}
// include("Color.xsh")

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

#pragma include("DecodeFloatVec4.xsh", "glsl")
/// @source http://aras-p.info/blog/2009/07/30/encoding-floats-to-rgba-the-final/
float xDecodeFloatVec4(vec4 v)
{
	return dot(v, vec4(1.0, 1.0 / 255.0, 1.0 / 65025.0, 1.0 / 16581375.0));
}
// include("DecodeFloatVec4.xsh")

vec3 pointLight(vec3 V, vec3 N, vec3 position, float range, vec3 color, float intensity)
{
	vec3 L = position - V;
	float dist = length(L);
	L = normalize(L);
	float NdotL = max(dot(N, L), 0.0);
	if (NdotL > 0.0)
	{
		float att = clamp(1.0 - (dist / range), 0.0, 1.0);
		return xGammaToLinear(color * intensity * NdotL * att);
	}
	return vec3(0.0);
}

struct PointLight
{
	vec3 Position;
	float Range;
	vec3 Color;
	float Intensity;
};

PointLight unpackPointLight(sampler2D data, float id, vec3 posMin, vec3 posMax, float rangeMax, float intensityMax)
{
	id              = ((id * 255.0) + 0.5) / 256.0;
	float x         = xDecodeFloatVec4(texture2D(data, vec2(0.0 / 8.0, id)));
	float y         = xDecodeFloatVec4(texture2D(data, vec2(1.0 / 8.0, id)));
	float z         = xDecodeFloatVec4(texture2D(data, vec2(2.0 / 8.0, id)));
	float range     = xDecodeFloatVec4(texture2D(data, vec2(3.0 / 8.0, id))) * rangeMax;
	vec3  color     =                  texture2D(data, vec2(4.0 / 8.0, id)).rgb;
	float intensity = xDecodeFloatVec4(texture2D(data, vec2(5.0 / 8.0, id))) * intensityMax;

	vec3 position = vec3(
		mix(posMin.x, posMax.x, x),
		mix(posMin.y, posMax.y, y),
		mix(posMin.z, posMax.z, z));

	return PointLight(
		position,
		range,
		color,
		intensity);
}

void main()
{
	vec4 base = texture2D(gm_BaseTexture, v_vTexCoord);
	if (base.a < 1.0)
	{
		discard;
	}
	base.rgb = xGammaToLinear(base.rgb);

	vec3 N = normalize(v_vNormal);
	vec3 lightColor = xGammaToLinear(vec3(0.1));

	// Directional light
	vec3 L = normalize(-vec3(-1.0, -1.0, -1.0));
	float NdotL = max(dot(N, L), 0.0);
	//lightColor += xGammaToLinear(vec3(1.0) * NdotL);

	// Point lights
	vec2 screenPos = xUnproject(v_vPosition);
	vec4 lightIndices = texture2D(u_texLightIndex, screenPos);

	if (lightIndices.r > 0.0)
	{
		PointLight l = unpackPointLight(u_texLightData, lightIndices.r, u_vBboxMin, u_vBboxMax, LIGHT_RADIUS_MAX, LIGHT_INTENSITY_MAX);
		lightColor += pointLight(v_vPositionWorld.xyz, N, l.Position, l.Range, l.Color, l.Intensity);
	}

	if (lightIndices.g > 0.0)
	{
		PointLight l = unpackPointLight(u_texLightData, lightIndices.g, u_vBboxMin, u_vBboxMax, LIGHT_RADIUS_MAX, LIGHT_INTENSITY_MAX);
		lightColor += pointLight(v_vPositionWorld.xyz, N, l.Position, l.Range, l.Color, l.Intensity);
	}

	if (lightIndices.b > 0.0)
	{
		PointLight l = unpackPointLight(u_texLightData, lightIndices.b, u_vBboxMin, u_vBboxMax, LIGHT_RADIUS_MAX, LIGHT_INTENSITY_MAX);
		lightColor += pointLight(v_vPositionWorld.xyz, N, l.Position, l.Range, l.Color, l.Intensity);
	}

	if (lightIndices.a > 0.0)
	{
		PointLight l = unpackPointLight(u_texLightData, lightIndices.a, u_vBboxMin, u_vBboxMax, LIGHT_RADIUS_MAX, LIGHT_INTENSITY_MAX);
		lightColor += pointLight(v_vPositionWorld.xyz, N, l.Position, l.Range, l.Color, l.Intensity);
	}

	gl_FragColor.rgb = xLinearToGamma(base.rgb * lightColor);
	gl_FragColor.a = 1.0;
}