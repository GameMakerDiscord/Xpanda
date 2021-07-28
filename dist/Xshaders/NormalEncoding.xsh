/// @param n View-space normal vector.
/// @return The normal vector encoded into two components.
/// @source http://aras-p.info/texts/CompactNormalStorage.html
Vec2 xEncodeNormal(Vec3 n)
{
	n.y = -n.y;
	float p = sqrt(n.z * 8.0 + 8.0);
	return (n.xy / p + 0.5);
}

/// @param enc View-space normal encoded into two components.
/// @return Decoded normal.
/// @source http://aras-p.info/texts/CompactNormalStorage.html
Vec3 xDecodeNormal(Vec2 enc)
{
	Vec2 fenc = enc * 4.0 - 2.0;
	float f = dot(fenc, fenc);
	float g = sqrt(1.0 - f * 0.25);
	Vec3 n;
	n.xy = fenc * g;
	n.z = 1.0 - f * 0.5;
	return n;
}
