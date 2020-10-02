varying vec3 v_vNormal;
varying vec2 v_vTexCoord;

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

void main()
{
	vec4 base = texture2D(gm_BaseTexture, v_vTexCoord);
	if (base.a < 1.0)
	{
		discard;
	}
	base.rgb = xGammaToLinear(base.rgb);

	vec3 N = normalize(v_vNormal);
	vec3 L = normalize(-vec3(-1.0, -1.0, -1.0));
	float NdotL = max(dot(N, L), 0.0);
	vec3 lightColor = xGammaToLinear(mix(vec3(0.3), vec3(1.0), NdotL));

	gl_FragColor.rgb = xLinearToGamma(base.rgb * lightColor);
	gl_FragColor.a = 1.0;
}