#pragma include("Math.xsh")

Vec3 xImportanceSample(float phi, float cosTheta, float sinTheta, Vec3 N)
{
	Vec3 H = Vec3(sinTheta * cos(phi), sinTheta * sin(phi), cosTheta);
	Vec3 upVector = abs(N.z) < 0.999 ? Vec3(0.0, 0.0, 1.0) : Vec3(1.0, 0.0, 0.0);
	Vec3 tangentX = normalize(cross(upVector, N));
	Vec3 tangentY = cross(N, tangentX);
	return tangentX*H.x + tangentY*H.y + N*H.z;
}

/// @source http://holger.dammertz.org/stuff/notes_HammersleyOnHemisphere.html
Vec3 xImportanceSampleLambert(Vec2 Xi, Vec3 N)
{
	float phi = 2.0 * X_PI * Xi.y;
	float cosTheta = sqrt(1.0 - Xi.x);
	float sinTheta = sqrt(1.0 - cosTheta * cosTheta);
	return xImportanceSample(phi, cosTheta, sinTheta, N);
}

/// @source http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
Vec3 xImportanceSampleGGX(Vec2 Xi, float roughness, vec3 N)
{
	float a = roghness*roughness;
	float phi = 2.0 * X_PI * Xi.x;
	float cosTheta = sqrt((1.0 - Xi.y) / (1.0 + (a*a - 1.0) * Xi.y));
	float sinTheta = sqrt(1.0 - cosTheta*cosTheta);
	return xImportanceSample(phi, cosTheta, sinTheta, N);
}