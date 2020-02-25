#pragma include("DepthEncoding.xsh")
#pragma include("CubeMapping.xsh")

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

/// @source https://learnopengl.com/Advanced-Lighting/Shadows/Shadow-Mapping
float xShadowMapPCF(Texture2D shadowMap, Vec2 texel, Vec2 uv, float compareZ)
{
	float shadow = 0.0;
	for (float x = -1.0; x <= 1.0; x += 1.0)
	{
		for (float y = -1.0; y <= 1.0; y += 1.0)
		{
			shadow += xShadowMapCompare(shadowMap, texel, uv.xy + (Vec2(x, y) * texel), compareZ);
		}
	}
	return (shadow / 9.0);
}

/// @source https://learnopengl.com/Advanced-Lighting/Shadows/Point-Shadows
float xShadowMapPCFCube(Texture2D shadowMap, Vec2 texel, Vec3 dir, float compareZ)
{
	Vec3 samples[20];
	samples[0] = Vec3( 1,  1,  1);
	samples[1] = Vec3( 1, -1,  1);
	samples[2] = Vec3(-1, -1,  1);
	samples[3] = Vec3(-1,  1,  1);
	samples[4] = Vec3( 1,  1, -1);
	samples[5] = Vec3( 1, -1, -1);
	samples[6] = Vec3(-1, -1, -1);
	samples[7] = Vec3(-1,  1, -1);
	samples[8] = Vec3( 1,  1,  0);
	samples[9] = Vec3( 1, -1,  0);
	samples[10] = Vec3(-1, -1,  0);
	samples[11] = Vec3(-1,  1,  0);
	samples[12] = Vec3( 1,  0,  1);
	samples[13] = Vec3(-1,  0,  1);
	samples[14] = Vec3( 1,  0, -1);
	samples[15] = Vec3(-1,  0, -1);
	samples[16] = Vec3( 0,  1,  1);
	samples[17] = Vec3( 0, -1,  1);
	samples[18] = Vec3( 0, -1, -1);
	samples[19] = Vec3( 0,  1, -1);

	float shadow = 0.0;
	for (int i = 0; i < 20; ++i)
	{
		shadow += xShadowMapCompare(shadowMap, texel, xVec3ToCubeUv(dir + samples[i], texel), compareZ);
	}
	return (shadow / 20.0);
}
