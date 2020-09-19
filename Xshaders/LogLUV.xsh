// Source: http://graphicrants.blogspot.com/2009/04/rgbm-color-encoding.html

// M matrix, for encoding
const Mat3 M = Mat3(
	0.2209, 0.3390, 0.4184,
	0.1138, 0.6780, 0.7319,
	0.0102, 0.1130, 0.2969);

// Inverse M matrix, for decoding
const Mat3 InverseM = Mat3(
	6.0014, -2.7008, -1.7996,
	-1.3320, 3.1029,-5.7721,
	0.3008, -1.0882, 5.6268);

Vec4 xEncodeLogLuv(Vec3 vRGB)
{
	Vec4 vResult;
#if XHLSL
	Vec3 Xp_Y_XYZp = mul(vRGB, M);
#else
	Vec3 Xp_Y_XYZp = M * vRGB;
#endif
	Xp_Y_XYZp = max(Xp_Y_XYZp, Vec3(1e-6, 1e-6, 1e-6));
	vResult.xy = Xp_Y_XYZp.xy / Xp_Y_XYZp.z;
	float Le = 2.0 * log2(Xp_Y_XYZp.y) + 127.0;
	vResult.w = Frac(Le);
	vResult.z = (Le - (floor(vResult.w * 255.0)) / 255.0) / 255.0;
	return vResult;
}

Vec3 xDecodeLogLuv(Vec4 vLogLuv)
{
	float Le = vLogLuv.z * 255.0 + vLogLuv.w;
	Vec3 Xp_Y_XYZp;
	Xp_Y_XYZp.y = exp2((Le - 127.0) / 2.0);
	Xp_Y_XYZp.z = Xp_Y_XYZp.y / vLogLuv.y;
	Xp_Y_XYZp.x = vLogLuv.x * Xp_Y_XYZp.z;
#if XHLSL
	Vec3 vRGB = mul(Xp_Y_XYZp, InverseM);
#else
	Vec3 vRGB = InverseM * Xp_Y_XYZp;
#endif
	return max(vRGB, Vec3(0.0, 0.0, 0.0));
}
