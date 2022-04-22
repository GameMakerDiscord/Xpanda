#pragma include("Cmp.xsh")

/// @desc Encodes depth and a normal vector into RGBA.
/// @param depth The depth to encode. Must be linearized.
/// @param N The world-space normal vector to encode.
/// @author TheSnidr
Vec4 xEncodeDepth20Normal12(float depth, Vec3 N)
{
	Vec4 enc;
	// Encode normal to green channel
	Vec3 aN = abs(N);
	float M = max(aN.x, max(aN.y, aN.z));
	Vec3 n = (N / M) * 0.5 + 0.5;

	// Figure out which primary direction the normal points in
	float dim = xIsEqual(N.x, -M);
	dim += (1.0 - abs(sign(dim))) * 2.0 * xIsEqual(N.y, M);
	dim += (1.0 - abs(sign(dim))) * 3.0 * xIsEqual(N.y, -M);
	dim += (1.0 - abs(sign(dim))) * 4.0 * xIsEqual(N.z, M);
	dim += (1.0 - abs(sign(dim))) * 5.0 * xIsEqual(N.z, -M);

	// Now that we've found the primary direction, we can pack the two remaining dimensions
	float d1 = Lerp(n.y, n.x, step(2.0, dim)); // Save y in the 1st slot if the primary direction is x+ or x-. Otherwise save x
	float d2 = Lerp(n.z, n.y, step(4.0, dim)); // Save z in the 2nd slot if the primary direction is along x or y. Otherwise save y
	float num = 26.0; // 6 * 26 * 26 is 4056, which is less than 2^20 = 4096

	// Find the unique value for this vector, from 0 to 4056 (12 bits)
	float encN = dim * num * num; // Save primary dimension
	encN += floor(clamp(d1 * num - 0.5, 0.0, num - 1.0) + 0.5); // Save first secondary dimension
	encN += floor(clamp(d2 * num - 0.5, 0.0, num - 1.0) + 0.5) * num; // Save second secondary dimension

	// Special case: Up-vector is stored to unused index 4056
	encN = Lerp(encN, 4056.0, xIsEqual(N.z, M) * xIsLess(abs(n.x - 0.5) + abs(n.y - 0.5), 0.01));

	// Special case: Down-vector is stored to unused index 4057
	encN = Lerp(encN, 4057.0, xIsEqual(N.z, -M) * xIsLess(abs(n.x - 0.5) + abs(n.y - 0.5), 0.01));

	// Encode depth into 16 bits
	float d = depth * 255.0;
	enc.r = floor(d) / 255.0;
	d = Frac(d) * 255.0;
	enc.g = floor(d) / 255.0;

	// Encode normal into 8 bits
	enc.b = mod(encN, 256.0) / 255.0;

	// Encode 4 bits of depth and 4 bits of normal into alpha channel
	enc.a = floor(Frac(d) * 16.0);
	enc.a += 16.0 * floor(encN / 256.0);
	enc.a /= 255.0;

	return enc;
}
