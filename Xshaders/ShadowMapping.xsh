#pragma include("DepthEncoding.xsh")

/// @source http://codeflow.org/entries/2013/feb/15/soft-shadow-mapping/
float xShadowMapCompare(Texture2D shadowMap, Vec2 texel, Vec2 uv, float compareZ)
{
	if (uv.x < 0.0 || uv.y < 0.0
		|| uv.x > 1.0 || uv.y > 1.0)
	{
		return 0.0;
	}
	Vec2 temp = uv.xy / texel + 0.5;
	Vec2 f = Frac(temp);
	Vec2 centroidUV = floor(temp) * texel;
	Vec2 pos = centroidUV;
	float lb = step(xDecodeDepth(Sample(shadowMap, pos).rgb), compareZ); // (0,0)
	pos.y += texel.y;
	float lt = step(xDecodeDepth(Sample(shadowMap, pos).rgb), compareZ); // (0,1)
	pos.x += texel.x;
	float rt = step(xDecodeDepth(Sample(shadowMap, pos).rgb), compareZ); // (1,1)
	pos.y -= texel.y;
	float rb = step(xDecodeDepth(Sample(shadowMap, pos).rgb), compareZ); // (1,0)
	return Lerp(
		Lerp(lb, lt, f.y),
		Lerp(rb, rt, f.y),
		f.x);
}