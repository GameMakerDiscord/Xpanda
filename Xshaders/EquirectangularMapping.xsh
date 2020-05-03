#pragma include("Math.xsh")

/// @param dir A sampling direction in world space.
/// @return UV coordinates on an equirectangular map.
Vec2 xVec3ToEquirectangularUv(Vec3 dir)
{
	Vec3 n = normalize(dir);
#if XGLSL
	return vec2((atan(n.y, n.x) / X_2_PI) + 0.5, acos(n.z) / X_PI);
#else
	return float2((atan2(n.x, n.y) / X_2_PI) + 0.5, acos(n.z) / X_PI);
#endif
}
