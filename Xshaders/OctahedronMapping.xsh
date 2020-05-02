/// @param dir Sampling direction vector in world-space.
/// @return UV coordinates on an octahedron map.
Vec2 xVec3ToOctahedronUv(Vec3 dir)
{
	dir *= 1.0 / dot(abs(dir), Vec3(1.0, 1.0, 1.0));
	float t = clamp(-dir.z, 0.0, 1.0);
	return (dir.xy + ((dir.x >= 0.0 && dir.y >= 0.0) ? t : -t) * 0.5 + 0.5);
}

/// @desc Converts octahedron UV into a world-space vector.
Vec3 xOctahedronUvToVec3Normalized(Vec2 uv)
{
	uv = uv * 2.0 - 1.0;
	Vec3 dir = Vec3(uv.x, uv.y, 1.0 - abs(uv.x) - abs(uv.y));
	float t = max(-dir.z, 0.0);
	dir.xy += (dir.x >= 0.0 && dir.y >= 0.0) ? -Vec2(t, t) : Vec2(t, t);
	return normalize(dir);
}
