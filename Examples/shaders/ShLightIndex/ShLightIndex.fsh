varying vec4 v_vPosition;

uniform float u_fZFar;
uniform vec2 u_vTanAspect;
uniform mat4 u_mViewInverse;
uniform vec4 u_vIndex;
uniform vec4 u_vLight; // (x, y, z, radius)

#pragma include("DepthEncoding.xsh", "glsl")
/// @param d Linearized depth to encode.
/// @return Encoded depth.
/// @source http://aras-p.info/blog/2009/07/30/encoding-floats-to-rgba-the-final/
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
/// @source http://aras-p.info/blog/2009/07/30/encoding-floats-to-rgba-the-final/
float xDecodeDepth(vec3 c)
{
	const float inv255 = 1.0 / 255.0;
	return c.x + (c.y * inv255) + (c.z * inv255 * inv255);
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
	vec2 posScreen = xUnproject(v_vPosition);
	vec3 depthEncoded = texture2D(gm_BaseTexture, posScreen).rgb;
	float depth = xDecodeDepth(depthEncoded) * u_fZFar;
	vec3 posView = xProject(u_vTanAspect, posScreen, depth);
	vec3 posWorld = (u_mViewInverse * vec4(posView, 1.0)).xyz;
	vec3 lightVec = u_vLight.xyz - posWorld;
	float dist = length(lightVec);
	if (dist > u_vLight.w)
	{
		discard;
	}
	gl_FragColor = u_vIndex;
}