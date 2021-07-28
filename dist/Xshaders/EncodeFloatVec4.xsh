/// @source http://aras-p.info/blog/2009/07/30/encoding-floats-to-rgba-the-final/
Vec4 xEncodeFloatVec4(float f)
{
	Vec4 enc = Vec4(1.0, 255.0, 65025.0, 16581375.0) * f;
	enc = frac(enc);
	enc -= enc.yzww * Vec4(1.0 / 255.0, 1.0 / 255.0, 1.0 / 255.0, 0.0);
	return enc;
}
