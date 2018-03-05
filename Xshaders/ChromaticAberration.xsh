/// @param direction  Direction of distortion.
/// @param distortion Per-channel distortion factor.
/// @source http://john-chapman-graphics.blogspot.cz/2013/02/pseudo-lens-flare.html
Vec3 xChromaticAberration(
	Texture2D tex,
	Vec2 uv, 
	Vec2 direction,
	Vec3 distortion)
{
	return Vec3(
		Sample(tex, uv + direction * distortion.r).r,
		Sample(tex, uv + direction * distortion.g).g,
		Sample(tex, uv + direction * distortion.b).b);
}