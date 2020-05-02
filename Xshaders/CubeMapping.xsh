#define X_CUBEMAP_POS_X 0
#define X_CUBEMAP_NEG_X 1
#define X_CUBEMAP_POS_Y 2
#define X_CUBEMAP_NEG_Y 3
#define X_CUBEMAP_POS_Z 4
#define X_CUBEMAP_NEG_Z 5

/// @param dir Sampling direction vector in world-space.
/// @param texel Texel size on cube side. Used to inset uv coordinates for
/// seamless filtering on edges. Use 0 to disable.
/// @return UV coordinates for the following cubemap layout:
/// +---------------------------+
/// |+X|-X|+Y|-Y|+Z|-Z|None|None|
/// +---------------------------+
Vec2 xVec3ToCubeUv(Vec3 dir, Vec2 texel)
{
	Vec3 dirAbs = abs(dir);

	int i = dirAbs.x > dirAbs.y ?
		(dirAbs.x > dirAbs.z ? 0 : 2) :
		(dirAbs.y > dirAbs.z ? 1 : 2);

	float uc, vc, ma;
	float o = 0.0;

	if (i == 0)
	{
		if (dir.x > 0.0)
		{
			uc = dir.y;
		}
		else
		{
			uc = -dir.y;
			o = 1.0;
		}
		vc = -dir.z;
		ma = dirAbs.x;
	}
	else if (i == 1)
	{
		if (dir.y > 0.0)
		{
			uc = -dir.x;
		}
		else
		{
			uc = dir.x;
			o = 1.0;
		}
		vc = -dir.z;
		ma = dirAbs.y;
	}
	else
	{
		uc = dir.y;
		if (dir.z > 0.0)
		{
			vc = +dir.x;
		}
		else
		{
			vc = -dir.x;
			o = 1.0;
		}
		ma = dirAbs.z;
	}

	float invL = 1.0 / length(ma);
	Vec2 uv = (Vec2(uc, vc) * invL + 1.0) * 0.5;
	uv = Lerp(texel * 1.5, 1.0 - texel * 1.5, uv);
	uv.x = (float(i) * 2.0 + o + uv.x) * 0.125;
	return uv;
}

/// @desc Gets normalized vector pointing to the UV on given cube side.
vec3 xCubeUvToVec3Normalized(vec2 uv, int cubeSide)
{
	uv = uv * 2.0 - 1.0;
	if (cubeSide == X_CUBEMAP_POS_X)
	{
		return normalize(vec3(+1.0, uv.x, -uv.y));
	}
	if (cubeSide == X_CUBEMAP_NEG_X)
	{
		return normalize(vec3(-1.0, -uv.x, -uv.y));
	}
	if (cubeSide == X_CUBEMAP_POS_Y)
	{
		return normalize(vec3(-uv.x, +1.0, -uv.y));
	}
	if (cubeSide == X_CUBEMAP_NEG_Y)
	{
		return normalize(vec3(uv.x, -1.0, -uv.y));
	}
	if (cubeSide == X_CUBEMAP_POS_Z)
	{
		return normalize(vec3(uv.y, uv.x, +1.0));
	}
	if (cubeSide == X_CUBEMAP_NEG_Z)
	{
		return normalize(vec3(-uv.y, uv.x, -1.0));
	}
	return vec3(0.0, 0.0, 0.0);
}