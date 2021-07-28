/// @desc Converts RGB color to HSV.
/// @source http://dystopiancode.blogspot.com/2012/06/hsv-rgb-conversion-algorithms-in-c.html
Vec3 xRGBToHSV(Vec3 rgb)
{
	float r = rgb.r;
	float g = rgb.g;
	float b = rgb.b;

	Vec3 color = Vec3(0.0, 0.0, 0.0);

	if (r < 0.0 || r > 1.0
		|| g < 0.0 || g > 1.0
		|| b < 0.0 || b > 1.0)
	{
		return color;
	}

	float M = max(r, max(g, b));
	float m = min(r, min(g, b));
	float c = M - m;

	color.b = M;

	if (c != 0.0)
	{
		if (M == r)
		{
			color.r = Mod(((g - b) / c), 6.0);
		}
		else if (M == g)
		{
			color.r = (b - r) / c + 2.0;
		}
		else
		{
			color.r = (r - g) / c + 4.0;
		}
		color.r *= 60.0;
		color.g = c / color.b;
	}

	return color;
}

/// @desc Converts HSV color to RGB.
/// @source http://dystopiancode.blogspot.com/2012/06/hsv-rgb-conversion-algorithms-in-c.html
Vec3 xHSVToRGB(Vec3 hsv)
{
	float h = hsv.x;
	float s = hsv.y;
	float v = hsv.z;

	if (h < 0.0 || h > 360.0
		|| s < 0.0 || s > 1.0
		|| v < 0.0 || v > 1.0)
	{
		return Vec3(0.0, 0.0, 0.0);
	}

	float c = v * s;
	float x = c * (1.0 - abs(Mod(h / 60.0, 2.0) - 1.0));
	float m = v - c;

	if (h >= 0.0 && h < 60.0)
	{
		return Vec3(c + m, x + m, m);
	}
	if (h >= 60.0 && h < 120.0)
	{
		return Vec3(x + m, c + m, m);
	}
	if (h >= 120.0 && h < 180.0)
	{
		return Vec3(m, c + m, x + m);
	}
	if (h >= 180.0 && h < 240.0)
	{
		return Vec3(m, x + m, c + m);
	}
	if (h >= 240.0 && h < 300.0)
	{
		return Vec3(x + m, m, c + m);
	}
	if (h >= 300.0 && h < 360.0)
	{
		return Vec3(c + m, m, x + m);
	}
	return Vec3(m, m, m);
}
