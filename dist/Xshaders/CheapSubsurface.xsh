/// @param subsurface Color in RGB and thickness/intensity in A.
/// @source https://colinbarrebrisebois.com/2011/03/07/gdc-2011-approximating-translucency-for-a-fast-cheap-and-convincing-subsurface-scattering-look/
Vec3 xCheapSubsurface(Vec4 subsurface, Vec3 eye, Vec3 normal, Vec3 light, Vec3 lightColor)
{
	const float fLTPower = 1.0;
	const float fLTScale = 1.0;
	Vec3 vLTLight = light + normal;
	float fLTDot = pow(clamp(dot(eye, -vLTLight), 0.0, 1.0), fLTPower) * fLTScale;
	float fLT = fLTDot * subsurface.a;
	return subsurface.rgb * lightColor * fLT;
}
