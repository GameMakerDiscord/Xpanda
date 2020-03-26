#pragma include("Projecting.xsh")
#pragma include("DepthEncoding.xsh")

/// @desc Reconstructs view-space normal vector from a depth buffer.
/// @source https://wickedengine.net/2019/09/22/improved-normal-reconstruction-from-depth/
Vec3 xNormalFromDepth(Vec3 origin, Vec2 texcoords, Vec2 texel, Texture2D texDepth, float clipFar)
{
	Vec2 right = texel * Vec2(+1.0, 0.0);
	Vec2 left = texel * Vec2(-1.0, 0.0);
	Vec2 down = texel * Vec2(0.0, +1.0);
	Vec2 up = texel * Vec2(0.0, -1.0);

	float depthRight = xDecodeDepth(Sample(texDepth, texcoords + right).rgb) * clipFar;
	float depthLeft = xDecodeDepth(Sample(texDepth, texcoords + left).rgb) * clipFar;
	float depthDown = xDecodeDepth(Sample(texDepth, texcoords + down).rgb) * clipFar;
	float depthUp = xDecodeDepth(Sample(texDepth, texcoords + up).rgb) * clipFar;

	Vec2 bestX = (abs(depthRight - origin.z) < abs(depthLeft - origin.z)) ? right : left;
	Vec2 bestY = (abs(depthDown - origin.z) < abs(depthUp - origin.z)) ? down : up;

	Vec3 p1, p2;

	if (bestX == right)
	{
		if (bestY == up)
		{
			p1 = xProject(u_vTanAspect, texcoords + right, depthRight);
			p2 = xProject(u_vTanAspect, texcoords + up, depthUp);
		}
		else
		{
			p1 = xProject(u_vTanAspect, texcoords + down, depthDown);
			p2 = xProject(u_vTanAspect, texcoords + right, depthRight);
		}
	}
	else
	{
		if (bestY == up)
		{
			p1 = xProject(u_vTanAspect, texcoords + up, depthUp);
			p2 = xProject(u_vTanAspect, texcoords + left, depthLeft);
		}
		else
		{
			p1 = xProject(u_vTanAspect, texcoords + left, depthLeft);
			p2 = xProject(u_vTanAspect, texcoords + down, depthDown);
		}
	}

	return normalize(cross(p2 - origin, p1 - origin));
}
