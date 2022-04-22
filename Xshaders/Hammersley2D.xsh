#if XHLSL
/// @desc Mirrors the binary representation of i at the decimal point???
/// @source http://holger.dammertz.org/stuff/notes_HammersleyOnHemisphere.html
float xRadicalInverseVDC(uint i)
{
	uint b = (i << 16) | (i >> 16);
	b = ((b & 0x55555555) << 1) | ((b & 0xAAAAAAAA) >> 1);
	b = ((b & 0x33333333) << 2) | ((b & 0xCCCCCCCC) >> 2);
	b = ((b & 0x0F0F0F0F) << 4) | ((b & 0xF0F0F0F0) >> 4);
	b = ((b & 0x00FF00FF) << 8) | ((b & 0xFF00FF00) >> 8);
	return float(b) * 2.3283064365386963 * 0.0000000001;
}
#else
/// @source https://learnopengl.com/PBR/IBL/Specular-IBL
float xVanDerCorpus(int n, int base)
{
	float invBase = 1.0 / float(base);
	float denom = 1.0;
	float result = 0.0;
	for (int i = 0; i < 32; ++i)
	{
		if (n > 0)
		{
			denom = Mod(float(n), 2.0);
			result += denom * invBase;
			invBase = invBase / 2.0;
			n = int(float(n) / 2.0);
		}
	}
	return result;
}
#endif

/// @desc Gets i-th point from sequence of uniformly distributed points on a unit square.
/// @param i The point index in sequence.
/// @param n The total size of the sequence.
/// @source http://holger.dammertz.org/stuff/notes_HammersleyOnHemisphere.html
Vec2 xHammersley2D(int i, int n)
{
#if XHLSL
	return Vec2(float(i) / float(n), xRadicalInverseVDC(i));
#else
	return Vec2(float(i) / float(n), xVanDerCorpus(i, 2));
#endif
}
