Mat4 xBillboard(Mat4 worldView)
{
	Mat4 m = worldView;
	m[0].xyz = Vec3(1.0, 0.0, 0.0);
	m[1].xyz = Vec3(0.0, -1.0, 0.0);
	m[2].xyz = Vec3(0.0, 0.0, 1.0);
	return m;
}

Mat4 xBillboardCylindrical(Mat4 worldView)
{
	Mat4 m = worldView;
	m[0].xyz = Vec3(1.0, 0.0, 0.0);
	m[1].xyz = -worldView[2].xyz;
	m[2].xyz = Vec3(0.0, 0.0, 1.0);
	return m;
}
