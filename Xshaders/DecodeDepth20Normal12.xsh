#pragma include("Cmp.xsh")

/// @desc Decodes depth from RGBA encoded using xEncodeDepth20Normal12.
/// @author TheSnidr
float xDecodeDepth20(Vec4 enc)
{
	return enc.r + (enc.g / 255.0) + (Frac(enc.a * 255.0 / 16.0) / 65025.0);
}

/// @desc Decodes world-space normal from RGBA encoded using xEncodeDepth20Normal12.
/// @author TheSnidr
Vec3 xDecodeNormal12(Vec4 enc)
{
	float val = enc.b * 255.0 + 256.0 * floor(enc.a * 255.0 / 16.0);

	//Special cases when vector points straight up or straight down
	float up = xIsEqual(val, 4056.0);
	float down = xIsEqual(val, 4057.0);

	float dim = floor(val / (26.0 * 26.0));
	val -= dim * 26.0 * 26.0;

	float v1 = (0.5 + Mod(val, 26.0)) / 26.0;
	float v2 = (0.5 + floor(val / 26.0)) / 26.0;

	Vec3 n = Vec3(
		Lerp(xIsEqual(dim, 0.0), v1, xIsGreater(dim, 1.0)),
		Lerp(Lerp(xIsEqual(dim, 2.0), v1, xIsLess(dim, 2.0)), v2, xIsGreater(dim, 3.0)),
		Lerp(v2, 1.0 - xIsEqual(dim, 5.0), xIsGreater(dim, 3.0)));
	n = Lerp(n, Vec3(0.5, 0.5, up), up + down);

	return normalize(n - Vec3(0.5, 0.5, 0.5));
}
