/// @param image The image to blur.
/// @param uv The current texture coordinates.
/// @param texel `(1 / imageWidth, 1 / imageHeight) * direction`, where `direction`
/// is `(1.0, 0.0)` for horizontal or `(0.0, 1.0)` for vertical blur.
/// @source http://rastergrid.com/blog/2010/09/efficient-gaussian-blur-with-linear-sampling/
Vec4 xGaussianBlur(Texture2D image, Vec2 uv, Vec2 texel)
{
	Vec4 color = Sample(image, uv) * 0.2270270270;
	Vec2 offset1 = texel * 1.3846153846;
	Vec2 offset2 = texel * 3.2307692308;
	color += Sample(image, uv + offset1) * 0.3162162162;
	color += Sample(image, uv - offset1) * 0.3162162162;
	color += Sample(image, uv + offset2) * 0.0702702703;
	color += Sample(image, uv - offset2) * 0.0702702703;
	return color;
}
