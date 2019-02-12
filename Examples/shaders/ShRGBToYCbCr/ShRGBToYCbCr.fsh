varying vec2 v_vTexCoord;

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
	// Output Y to the red channel and Cb, Cr interleaved
	// in a checkerboard pattern to the green channel.
	vec4 base = texture2D(gm_BaseTexture, v_vTexCoord);
	vec3 YCbCr = xRGBtoYCbCr(base.rgb);
	bool interleave = mod(floor(v_vTexCoord.x * u_vScreenSize.x), 2.0) == mod(floor(v_vTexCoord.y * u_vScreenSize.y), 2.0);
	gl_FragColor = vec4(
		YCbCr.r,
		interleave ? YCbCr.g : YCbCr.b,
		0.0,
		1.0);
}