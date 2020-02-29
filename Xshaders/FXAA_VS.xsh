// Source: https://www.geeks3d.com/20110405/fxaa-fast-approximate-anti-aliasing-demo-glsl-opengl-test-radeon-geforce/3/

/// @param texCoord Texture coordinates.
/// @param texel    Vec2(1.0 / textureWidth, 1.0 / textureHeight)
Vec4 xFxaaFragPos(Vec2 texCoord, Vec2 texel)
{
	Vec4 pos;
	pos.xy = texCoord;
	pos.zw = texCoord - (texel * 0.75);
	return pos;
}