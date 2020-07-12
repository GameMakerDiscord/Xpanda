#define X_PI   3.14159265359
#define X_2_PI 6.28318530718

/// @return x^2
float xPow2(float x) { return (x * x); }

/// @return x^3
float xPow3(float x) { return (x * x * x); }

/// @return x^4
float xPow4(float x) { return (x * x * x * x); }

/// @return x^5
float xPow5(float x) { return (x * x * x * x * x); }

/// @return arctan2(x,y)
float xAtan2(float x, float y)
{
#if XHLSL
	return atan2(x, y);
#else
	return atan(y, x);
#endif
}

/// @return Direction from point `from` to point `to` in degrees (0-360 range).
float xPointDirection(Vec2 from, Vec2 to)
{
	float x = xAtan2(from.x - to.x, from.y - to.y);
	return ((x > 0.0) ? x : (2.0 * X_PI + x)) * 180.0 / X_PI;
}
