// Source: https://gamedev.stackexchange.com/questions/169508/octahedral-impostors-octahedral-mapping

/// @param dir Sampling dir vector in world-space.
/// @return UV coordinates on an octahedron map.
Vec2 xVec3ToOctahedronUv(Vec3 dir)
{
	Vec3 octant = sign(dir);
	float sum = dot(dir, octant);
	Vec3 octahedron = dir / sum;
	if (octahedron.z < 0.0)
	{
		Vec3 absolute = abs(octahedron);
		octahedron.xy = octant.xy * Vec2(1.0 - absolute.y, 1.0 - absolute.x);
	}
	return octahedron.xy * 0.5 + 0.5;
}

/// @desc Converts octahedron UV into a world-space vector.
Vec3 xOctahedronUvToVec3Normalized(Vec2 uv)
{
	Vec3 position = Vec3(2.0 * (uv - 0.5), 0);
	Vec2 absolute = abs(position.xy);
	position.z = 1.0 - absolute.x - absolute.y;
	if (position.z < 0.0)
	{
		position.xy = sign(position.xy) * Vec2(1.0 - absolute.y, 1.0 - absolute.x);
	}
	return position;
}
