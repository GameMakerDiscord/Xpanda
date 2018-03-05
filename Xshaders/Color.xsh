/// @desc Converts gamma space color to linear space.
Vec3 xGammaToLinear(Vec3 rgb)
{
	return pow(abs(rgb), 2.2);
}

/// @desc Converts linear space color to gamma space.
Vec3 xLinearToGamma(Vec3 rgb)
{
	return pow(abs(rgb), 1.0 / 2.2);
}

/// @desc Gets color's luminance.
float xLuminance(Vec3 rgb)
{
	return (0.2126 * rgb.r + 0.7152 * rgb.g + 0.0722 * rgb.b);
}