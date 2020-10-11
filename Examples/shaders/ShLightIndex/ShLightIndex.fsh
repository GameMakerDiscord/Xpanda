varying vec4 v_vPosition;

uniform float u_fZFar;
uniform vec2 u_vTanAspect;
uniform mat4 u_mViewInverse;
uniform vec4 u_vIndex;
uniform vec4 u_vLight; // (x, y, z, radius)

#pragma include("DecodeDepth20Normal12.xsh", "glsl")
/// @desc Evalutes to 1.0 if a < b, otherwise to 0.0.
#define xIsLess(a, b) (((a) < (b)) ? 1.0 : 0.0)

/// @desc Evalutes to 1.0 if a <= b, otherwise to 0.0.
#define xIsLessEqual(a, b) (((a) <= (b)) ? 1.0 : 0.0)

/// @desc Evalutes to 1.0 if a == b, otherwise to 0.0.
#define xIsEqual(a, b) (((a) == (b)) ? 1.0 : 0.0)

/// @desc Evalutes to 1.0 if a != b, otherwise to 0.0.
#define xIsNotEqual(a, b) (((a) != (b)) ? 1.0 : 0.0)

/// @desc Evalutes to 1.0 if a >= b, otherwise to 0.0.
#define xIsGreaterEqual(a, b) (((a) >= (b)) ? 1.0 : 0.0)

/// @desc Evalutes to 1.0 if a > b, otherwise to 0.0.
#define xIsGreater(a, b) (((a) > (b)) ? 1.0 : 0.0)

// Author: TheSnidr

float xDecodeDepth20(vec4 enc)
{
	return enc.r + (enc.g / 255.0) + (fract(enc.a * 255.0 / 16.0) / 65025.0);
}

vec3 xDecodeNormal12(vec4 enc)
{
	float val = enc.b * 255.0 + 256.0 * floor(enc.a * 255.0 / 16.0);
	
	//Special cases when vector points straight up or straight down
	float up = xIsEqual(val, 4056.0);
	float down = xIsEqual(val, 4057.0);
	
	float dim = floor(val / (26.0 * 26.0));
	val -= dim * 26.0 * 26.0;
	
	float v1 = (0.5 + mod(val, 26.0)) / 26.0;
	float v2 = (0.5 + floor(val / 26.0)) / 26.0;
	
	vec3 n = vec3(
		mix(xIsEqual(dim, 0.0), v1, xIsGreater(dim, 1.0)),
		mix(mix(xIsEqual(dim, 2.0), v1, xIsLess(dim, 2.0)), v2, xIsGreater(dim, 3.0)),
		mix(v2, 1.0 - xIsEqual(dim, 5.0), xIsGreater(dim, 3.0)));
	n = mix(n, vec3(0.5, 0.5, up), up + down);
	
	return normalize(n - vec3(0.5, 0.5, 0.5));
}
// include("DecodeDepth20Normal12.xsh")

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
	vec4 gbuffer = texture2D(gm_BaseTexture, posScreen);
	float depth = xDecodeDepth20(gbuffer) * u_fZFar;
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