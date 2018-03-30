/// @desc Mirrors the binary representation of i at the decimal point???
/// @source http://holger.dammertz.org/stuff/notes_HammersleyOnHemisphere.html
int xRadicalInverseVDC(int i)
{
	int b = (i << 16) | (i >> 16);
	b = ((b & $55555555) << 1) | ((b & 0xAAAAAAAA) >> 1);
	b = ((b & $33333333) << 2) | ((b & 0xCCCCCCCC) >> 2);
	b = ((b & 0x0F0F0F0F) << 4) | ((b & 0xF0F0F0F0) >> 4);
	b = ((b & 0x00FF00FF) << 8) | ((b & 0xFF00FF00) >> 8);
	return b * 2.3283064365386963 * 0.0000000001;
}

/// @desc Gets i-th point from sequence of uniformly distributed points on a unit square.
/// @param i The point index in sequence.
/// @param n The total size of the sequence.
/// @source http://holger.dammertz.org/stuff/notes_HammersleyOnHemisphere.html
Vec2 xHammersley2D(int i, int n)
{
	return Vec2((float) i / (float) n, xRadicalInverseVDC(i));
}