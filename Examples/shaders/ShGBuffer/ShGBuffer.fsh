varying vec3 v_vNormal;
varying vec2 v_vTexCoord;
varying float v_fDepth;

#pragma include("EncodeDepth20Normal12.xsh", "glsl")
/// @desc Evalutes to 1.0 if a < b, otherwise to 0.0.
#define xIsLess(a, b) (((a) < (b)) ? 1.0 : 0.0)

/// @desc Evalutes to 1.0 if a <= b, otherwise to 0.0.
#define xIsLessEqual(a, b) (((a) <= (b)) ? 1.0 : 0.0)

/// @desc Evalutes to 1.0 if a == b, otherwise to 0.0.
#define xIsEqual(a, b) (((a) == (b)) ? 1.0 : 0.0)

/// @desc Evalutes to 1.0 if a != b, otherwise to 0.0.
#define xIsNotEqual(a, b) (((a) != (b)) ? 1.0 : 0.0)

/// @desc Evalutes to 1.0 if a >= b, otherwise to 0.0.
#define xIsGreaterEqual(a, b) (((a) >= (b)) ? 1.0 : 0.0)

/// @desc Evalutes to 1.0 if a > b, otherwise to 0.0.
#define xIsGreater(a, b) (((a) > (b)) ? 1.0 : 0.0)

// Author: TheSnidr

vec4 xEncodeDepth20Normal12(float depth, vec3 N)
{
	vec4 enc;
	// Encode normal to green channel
	vec3 aN = abs(N);
	float M = max(aN.x, max(aN.y, aN.z));
	vec3 n = (N / M) * 0.5 + 0.5;
	
	// Figure out which primary direction the normal points in
	float dim = xIsEqual(N.x, -M);
	dim += (1.0 - abs(sign(dim))) * 2.0 * xIsEqual(N.y, M);
	dim += (1.0 - abs(sign(dim))) * 3.0 * xIsEqual(N.y, -M);
	dim += (1.0 - abs(sign(dim))) * 4.0 * xIsEqual(N.z, M);
	dim += (1.0 - abs(sign(dim))) * 5.0 * xIsEqual(N.z, -M);
	
	// Now that we've found the primary direction, we can pack the two remaining dimensions
	float d1 = mix(n.y, n.x, step(2.0, dim)); // Save y in the 1st slot if the primary direction is x+ or x-. Otherwise save x
	float d2 = mix(n.z, n.y, step(4.0, dim)); // Save z in the 2nd slot if the primary direction is along x or y. Otherwise save y
	float num = 26.0; // 6 * 26 * 26 is 4056, which is less than 2^20 = 4096
	
	// Find the unique value for this vector, from 0 to 4056 (12 bits)
	float encN = dim * num * num; // Save primary dimension
	encN += floor(clamp(d1 * num - 0.5, 0.0, num - 1.0) + 0.5); // Save first secondary dimension
	encN += floor(clamp(d2 * num - 0.5, 0.0, num - 1.0) + 0.5) * num; // Save second secondary dimension
	
	// Special case: Up-vector is stored to unused index 4056
	encN = mix(encN, 4056.0, xIsEqual(N.z, M) * xIsLess(abs(n.x - 0.5) + abs(n.y - 0.5), 0.01));
	
	// Special case: Down-vector is stored to unused index 4057
	encN = mix(encN, 4057.0, xIsEqual(N.z, -M) * xIsLess(abs(n.x - 0.5) + abs(n.y - 0.5), 0.01));
	
	// Encode depth into 16 bits
	float d = depth * 255.0;
	enc.r = floor(d) / 255.0;
	d = fract(d) * 255.0;
	enc.g = floor(d) / 255.0;
	
	// Encode normal into 8 bits
	enc.b = mod(encN, 256.0) / 255.0;
	
	// Encode 4 bits of depth and 4 bits of normal into alpha channel
	enc.a = floor(fract(d) * 16.0);
	enc.a += 16.0 * floor(encN / 256.0);
	enc.a /= 255.0;
	
	return enc;
}
// include("EncodeDepth20Normal12.xsh")

void main()
{
	if (texture2D(gm_BaseTexture, v_vTexCoord).a < 1.0)
	{
		discard;
	}
	vec3 N = normalize(v_vNormal);
	gl_FragColor = xEncodeDepth20Normal12(v_fDepth, N);
}