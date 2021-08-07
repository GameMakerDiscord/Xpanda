// Source: https://stackoverflow.com/a/42179924
Vec4 xCubic(float v)
{
	Vec4 n = Vec4(1.0, 2.0, 3.0, 4.0) - v;
	Vec4 s = n * n * n;
	float x = s.x;
	float y = s.y - (4.0 * s.x);
	float z = s.z - (4.0 * s.y) + (6.0 * s.x);
	float w = 6.0 - x - y - z;
	return Vec4(x, y, z, w) * (1.0 / 6.0);
}

Vec4 xTextureBicubic(Texture2D tex, Vec2 uv, Vec2 texel)
{
	Vec2 texCoords = uv / texel - 0.5;

	Vec2 fxy = frac(texCoords);
	texCoords -= fxy;

	Vec4 xcubic = xCubic(fxy.x);
	Vec4 ycubic = xCubic(fxy.y);

	Vec4 c = texCoords.xxyy + Vec2(-0.5, +1.5).xyxy;

	Vec4 s = Vec4(xcubic.xz + xcubic.yw, ycubic.xz + ycubic.yw);
	Vec4 offset = c + Vec4(xcubic.yw, ycubic.yw) / s;

	offset *= texel.xxyy;

	Vec4 sample0 = Sample(tex, offset.xz);
	Vec4 sample1 = Sample(tex, offset.yz);
	Vec4 sample2 = Sample(tex, offset.xw);
	Vec4 sample3 = Sample(tex, offset.yw);

	float sx = s.x / (s.x + s.y);
	float sy = s.z / (s.z + s.w);

	return Lerp(
		Lerp(sample3, sample2, sx),
		Lerp(sample1, sample0, sx),
		sy);
}
