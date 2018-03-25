/// @param N  Interpolated vertex normal.
/// @param V  View vector (vertex to eye).
/// @param uv Texture coordinates.
/// @return TBN matrix.
/// @source http://www.thetenthplanet.de/archives/1180
Mat3 xCotangentFrame(Vec3 N, Vec3 V, Vec2 uv)
{
	Vec3 p = -V;
	Vec3 dp1 = DDX(p);
	Vec3 dp2 = DDY(p);
	Vec2 duv1 = DDX(uv);
	Vec2 duv2 = DDY(uv);
	Vec3 dp2perp = cross(dp2, N);
	Vec3 dp1perp = cross(N, dp1);
	Vec3 T = dp2perp*duv1.x + dp1perp*duv2.x;
	Vec3 B = dp2perp*duv1.y + dp1perp*duv2.y;
	float invmax = Rsqrt(max(dot(T, T), dot(B, B)));
	return Mat3(T*invmax, B*invmax, N);
}