/// @desc Multiplies quaternions q1 and q2.
Vec4 xQuaternionMultiply(Vec4 _q1, Vec4 _q2)
{
	float _q10 = _q1.x;
	float _q11 = _q1.y;
	float _q12 = _q1.z;
	float _q13 = _q1.w;
	float _q20 = _q2.x;
	float _q21 = _q2.y;
	float _q22 = _q2.z;
	float _q23 = _q2.w;

	Vec4 q = Vec4(0.0, 0.0, 0.0, 0.0);

	q.x = _q11 * _q22 - _q12 * _q21
		+ _q13 * _q20 + _q10 * _q23;
	q.y = _q12 * _q20 - _q10 * _q22
		+ _q13 * _q21 + _q11 * _q23;
	q.z = _q10 * _q21 - _q11 * _q20
		+ _q13 * _q22 + _q12 * _q23;
	q.w = _q13 * _q23 - _q10 * _q20
		- _q11 * _q21 - _q12 * _q22;

	return q;
}

/// @desc Rotates vector v by quaternion q.
Vec4 xQuaternionRotate(Vec4 q, Vec4 v)
{
	q = normalize(q);
	Vec4 V = Vec4(v.x, v.y, v.z, 0.0);
	Vec4 conjugate = Vec4(-q.x, -q.y, -q.z, q.w);
	Vec4 rot = xQuaternionMultiply(q, V);
	rot = xQuaternionMultiply(rot, conjugate);
	return rot;
}
