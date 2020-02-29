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
	float shadow = 0.0;
	Vec2 texelY = Vec2(texel.y, texel.y);
	shadow += xShadowMapCompare(shadowMap, texel, xVec3ToCubeUv(dir + Vec3( 1.0, -1.0,  1.0), texelY), compareZ);
	shadow += xShadowMapCompare(shadowMap, texel, xVec3ToCubeUv(dir + Vec3( 1.0,  1.0,  1.0), texelY), compareZ);
	shadow += xShadowMapCompare(shadowMap, texel, xVec3ToCubeUv(dir + Vec3(-1.0, -1.0,  1.0), texelY), compareZ);
	shadow += xShadowMapCompare(shadowMap, texel, xVec3ToCubeUv(dir + Vec3(-1.0,  1.0,  1.0), texelY), compareZ);
	shadow += xShadowMapCompare(shadowMap, texel, xVec3ToCubeUv(dir + Vec3( 1.0,  1.0, -1.0), texelY), compareZ);
	shadow += xShadowMapCompare(shadowMap, texel, xVec3ToCubeUv(dir + Vec3( 1.0, -1.0, -1.0), texelY), compareZ);
	shadow += xShadowMapCompare(shadowMap, texel, xVec3ToCubeUv(dir + Vec3(-1.0, -1.0, -1.0), texelY), compareZ);
	shadow += xShadowMapCompare(shadowMap, texel, xVec3ToCubeUv(dir + Vec3(-1.0,  1.0, -1.0), texelY), compareZ);
	shadow += xShadowMapCompare(shadowMap, texel, xVec3ToCubeUv(dir + Vec3( 1.0,  1.0,  0.0), texelY), compareZ);
	shadow += xShadowMapCompare(shadowMap, texel, xVec3ToCubeUv(dir + Vec3( 1.0, -1.0,  0.0), texelY), compareZ);
	shadow += xShadowMapCompare(shadowMap, texel, xVec3ToCubeUv(dir + Vec3(-1.0, -1.0,  0.0), texelY), compareZ);
	shadow += xShadowMapCompare(shadowMap, texel, xVec3ToCubeUv(dir + Vec3(-1.0,  1.0,  0.0), texelY), compareZ);
	shadow += xShadowMapCompare(shadowMap, texel, xVec3ToCubeUv(dir + Vec3( 1.0,  0.0,  1.0), texelY), compareZ);
	shadow += xShadowMapCompare(shadowMap, texel, xVec3ToCubeUv(dir + Vec3(-1.0,  0.0,  1.0), texelY), compareZ);
	shadow += xShadowMapCompare(shadowMap, texel, xVec3ToCubeUv(dir + Vec3( 1.0,  0.0, -1.0), texelY), compareZ);
	shadow += xShadowMapCompare(shadowMap, texel, xVec3ToCubeUv(dir + Vec3(-1.0,  0.0, -1.0), texelY), compareZ);
	shadow += xShadowMapCompare(shadowMap, texel, xVec3ToCubeUv(dir + Vec3( 0.0,  1.0,  1.0), texelY), compareZ);
	shadow += xShadowMapCompare(shadowMap, texel, xVec3ToCubeUv(dir + Vec3( 0.0, -1.0,  1.0), texelY), compareZ);
	shadow += xShadowMapCompare(shadowMap, texel, xVec3ToCubeUv(dir + Vec3( 0.0, -1.0, -1.0), texelY), compareZ);
	shadow += xShadowMapCompare(shadowMap, texel, xVec3ToCubeUv(dir + Vec3( 0.0,  1.0, -1.0), texelY), compareZ);
	return (shadow / 20.0);
}
