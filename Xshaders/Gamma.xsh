#define X_GAMMA 2.2

/// @desc Converts color from gamma space to linear space.
Vec3 xGammaToLinear(Vec3 gamma)
{
#if XGLSL
	return vec3(
		pow(gamma.r, X_GAMMA),
		pow(gamma.g, X_GAMMA),
		pow(gamma.b, X_GAMMA));
#else
	return pow(gamma, X_GAMMA);
#endif
}

/// @desc Converts color from linear space to gamma space.
Vec3 xLinearToGamma(Vec3 lin)
{
#if XGLSL
	return vec3(
		pow(lin.r, 1.0 / X_GAMMA),
		pow(lin.g, 1.0 / X_GAMMA),
		pow(lin.b, 1.0 / X_GAMMA));
#else
	return pow(lin, 1.0 / X_GAMMA);
#endif
}
