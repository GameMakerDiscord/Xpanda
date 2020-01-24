Vec2 xVec3ToOctahedronUv(Vec3 n)
{
	n *= 1.0 / dot(abs(n), 1.0);
	float t = clamp(-n.z, 0.0, 1.0);
	return (n.xy + ((n.xy >= 0.0) ? t : -t) * 0.5 + 0.5);
}

Vec3 xOctahedronUvToVec3Normalized(Vec2 f)
{
	f = f * 2.0 - 1.0;
	Vec3 n = Vec3(f.x, f.y, 1.0 - abs(f.x) - abs(f.y));
	float t = max(-n.z, 0.0);
	n.xy += (n.xy >= 0.0) ? -Vec2(t.x, t.x) : Vec2(t.x, t.x);
	return normalize(n);
}
