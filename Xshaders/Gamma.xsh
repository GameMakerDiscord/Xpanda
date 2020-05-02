#define X_GAMMA 2.2

/// @desc Converts color from gamma space to linear space.
Vec3 xGammaToLinear(Vec3 gamma)
{
#if XGLSL
	return pow(gamma, vec3(X_GAMMA));
#else
	return pow(gamma, X_GAMMA);
#endif
}

/// @desc Converts color from linear space to gamma space.
Vec3 xLinearToGamma(Vec3 lin)
{
#if XGLSL
	return pow(lin, vec3(1.0 / X_GAMMA));
#else
	return pow(lin, 1.0 / X_GAMMA);
#endif
}
