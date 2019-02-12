varying vec2 v_vTexCoord;

uniform vec2 u_vTexel;      // (1/screenWidth,1/screenHeight)
uniform vec2 u_vScreenSize; // (screenWidth,screenHeight)

#pragma include("YCbCr.xsh", "glsl")
/// @desc Converts RGB space color to YCbCr space color.
vec3 xRGBtoYCbCr(vec3 rgb)
{
	return vec3(
		0.299 * rgb.r + 0.587 * rgb.g + 0.114 * rgb.b,
		0.5 + (-0.168 * rgb.r - 0.331 * rgb.g + 0.5 * rgb.b),
		0.5 + (0.5 * rgb.r - 0.418 * rgb.g - 0.081 * rgb.b));
}

/// @desc Converts YCbCr space color to RGB space color.
vec3 xYCbCrToRGB(vec3 YCbCr)
{
	return vec3(
		YCbCr.r + 1.402 * (YCbCr.b - 0.5),
		YCbCr.r - 0.344 * (YCbCr.g - 0.5) - 0.714 * (YCbCr.b - 0.5),
		YCbCr.r + 1.772 * (YCbCr.g - 0.5));
}
// include("YCbCr.xsh")

void main()
{
	// Retrieve original RGB color from interleaved YCbCr.
	vec4 base = texture2D(gm_BaseTexture, v_vTexCoord);
	bool interleave = mod(floor(v_vTexCoord.x * u_vScreenSize.x), 2.0) == mod(floor(v_vTexCoord.y * u_vScreenSize.y), 2.0);
	float Cb = interleave ? base.g : texture2D(gm_BaseTexture, v_vTexCoord + vec2(1.0, 0.0) * u_vTexel).g;
	float Cr = interleave ? texture2D(gm_BaseTexture, v_vTexCoord - vec2(1.0, 0.0) * u_vTexel).g : base.g;
	gl_FragColor.rgb = xYCbCrToRGB(vec3(base.r, Cb, Cr));
	gl_FragColor.a = 1.0;
}