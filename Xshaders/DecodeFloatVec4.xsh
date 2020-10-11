/// @source http://aras-p.info/blog/2009/07/30/encoding-floats-to-rgba-the-final/
float xDecodeFloatVec4(Vec4 v)
{
	return dot(v, Vec4(1.0, 1.0 / 255.0, 1.0 / 65025.0, 1.0 / 16581375.0));
}
