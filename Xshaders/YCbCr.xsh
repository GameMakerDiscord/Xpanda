/// @desc Converts RGB space color to YCbCr space color.
Vec3 xRGBtoYCbCr(Vec3 rgb)
{
	return Vec3(
		0.299 * rgb.r + 0.587 * rgb.g + 0.114 * rgb.b,
		0.5 + (-0.168 * rgb.r - 0.331 * rgb.g + 0.5 * rgb.b),
		0.5 + (0.5 * rgb.r - 0.418 * rgb.g - 0.081 * rgb.b));
}

/// @desc Converts YCbCr space color to RGB space color.
Vec3 xYCbCrToRGB(Vec3 YCbCr)
{
	return Vec3(
		YCbCr.r + 1.402 * (YCbCr.b - 0.5),
		YCbCr.r - 0.344 * (YCbCr.g - 0.5) - 0.714 * (YCbCr.b - 0.5),
		YCbCr.r + 1.772 * (YCbCr.g - 0.5));
}