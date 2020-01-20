/// @param color The original RGB color.
/// @param lut   Texture of color-grading lookup tables (256x256, each LUT is
///              256x16, placed in rows). Needs to have interpolation enabled!
/// @param index The index of the lut to use (0 = first row, 1 = second row,
///              ..., 15 = last row).
Vec3 xColorGrade(Vec3 color, Texture2D lut, float index)
{
	Vec2 uv;
	uv.x = color.x * 0.05859375;
	uv.y = color.y * 0.05859375 + index * 0.0625;
	float b15 = color.b * 15.0;
	float z0 = floor(b15) * 0.0625;
	float z1 = z0 + 0.0625;
	Vec2 uv2 = uv + 0.001953125;
	return Lerp(
		Sample(lut, uv2 + Vec2(z0, 0.0)).rgb,
		Sample(lut, uv2 + Vec2(z1, 0.0)).rgb,
		Frac(b15));
}
