/// @source https://colinbarrebrisebois.com/2011/03/07/gdc-2011-approximating-translucency-for-a-fast-cheap-and-convincing-subsurface-scattering-look/
Vec3 xCheapSubsurface(Vec3 subsurfaceColor, float subsurfaceIntensity, Vec3 eye, Vec3 normal, Vec3 light, Vec3 lightColor)
{
	const float fLTPower = 1.0;
	const float fLTScale = 1.0;
	Vec3 vLTLight = light + normal;
	float fLTDot = pow(clamp(dot(eye, -vLTLight), 0.0, 1.0), fLTPower) * fLTScale;
	float fLT = fLTDot * subsurfaceIntensity;
	return subsurfaceColor * lightColor * fLT;
}
