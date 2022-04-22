#pragma include("DepthEncoding.xsh")
#pragma include("CubeMapping.xsh")

/// @source https://iquilezles.org/www/articles/hwinterpolation/hwinterpolation.htm
float xShadowMapCompare(Texture2D shadowMap, Vec2 texel, Vec2 uv, float compareZ)
{
	if (uv.x < 0.0 || uv.y < 0.0
		|| uv.x > 1.0 || uv.y > 1.0)
	{
		return 0.0;
	}
	Vec2 res = 1.0 / texel;
	Vec2 st = uv*res - 0.5;
	Vec2 iuv = floor(st);
	Vec2 fuv = Frac(st);
	vec3 s = Sample(shadowMap, (iuv+Vec2(0.5,0.5))/res).rgb;
	if (s == vec3(1.0, 0.0, 0.0))
	{
		return 0.0;
	}
	float a = (xDecodeDepth(s) < compareZ - 0.002) ? 1.0 : 0.0;
	float b = (xDecodeDepth(Sample(shadowMap, (iuv+Vec2(1.5,0.5))/res).rgb) < compareZ - 0.002) ? 1.0 : 0.0;
	float c = (xDecodeDepth(Sample(shadowMap, (iuv+Vec2(0.5,1.5))/res).rgb) < compareZ - 0.002) ? 1.0 : 0.0;
	float d = (xDecodeDepth(Sample(shadowMap, (iuv+Vec2(1.5,1.5))/res).rgb) < compareZ - 0.002) ? 1.0 : 0.0;
	return Lerp(
		Lerp(a, b, fuv.x),
		Lerp(c, d, fuv.x),
		fuv.y);
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
	samples[0] = Vec3( 1.0,  1.0,  1.0);
	samples[1] = Vec3( 1.0, -1.0,  1.0);
	samples[2] = Vec3(-1.0, -1.0,  1.0);
	samples[3] = Vec3(-1.0,  1.0,  1.0);
	samples[4] = Vec3( 1.0,  1.0, -1.0);
	samples[5] = Vec3( 1.0, -1.0, -1.0);
	samples[6] = Vec3(-1.0, -1.0, -1.0);
	samples[7] = Vec3(-1.0,  1.0, -1.0);
	samples[8] = Vec3( 1.0,  1.0,  0.0);
	samples[9] = Vec3( 1.0, -1.0,  0.0);
	samples[10] = Vec3(-1.0, -1.0,  0.0);
	samples[11] = Vec3(-1.0,  1.0,  0.0);
	samples[12] = Vec3( 1.0,  0.0,  1.0);
	samples[13] = Vec3(-1.0,  0.0,  1.0);
	samples[14] = Vec3( 1.0,  0.0, -1.0);
	samples[15] = Vec3(-1.0,  0.0, -1.0);
	samples[16] = Vec3( 0.0,  1.0,  1.0);
	samples[17] = Vec3( 0.0, -1.0,  1.0);
	samples[18] = Vec3( 0.0, -1.0, -1.0);
	samples[19] = Vec3( 0.0,  1.0, -1.0);

	float shadow = 0.0;
	Vec2 texelY = Vec2(texel.y, texel.y);
	for (int i = 0; i < 20; ++i)
	{
		shadow += xShadowMapCompare(shadowMap, texel, xVec3ToCubeUv(dir + samples[i], texelY), compareZ);
	}
	return (shadow / 20.0);
}
